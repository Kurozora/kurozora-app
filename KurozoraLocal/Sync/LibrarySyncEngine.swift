//
//  LibrarySyncEngine.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import Network
import os.log

private nonisolated let syncLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibrarySyncEngine")

/// Drives the multiplexed library delta sync into the local store.
actor LibrarySyncEngine {
	// MARK: - Properties
	/// Returns the singleton `LibrarySyncEngine` instance.
	static let shared = LibrarySyncEngine()

	/// The maximum number of rows requested per stream, per round.
	private let batchLimit = 500

	/// The in-flight sync tasks per user.
	private var inFlight: [String: Task<Void, Never>] = [:]

	/// Users whose in-flight sync runs once more after it finishes.
	private var rerunRequested: Set<String> = []

	/// The users whose last attempt failed.
	private var pendingRetries: Set<String> = []

	/// Users whose next sync drops the entry cursor first.
	private var fullPullRequested: Set<String> = []

	/// The earliest time a throttled user's pulls may resume.
	private var throttledUntil: [String: Date] = [:]

	/// The tasks waiting out a throttle window, per user.
	private var throttleRetryTasks: [String: Task<Void, Never>] = [:]

	/// The throttle wait when the server names none.
	private let defaultThrottleInterval: TimeInterval = 60

	/// The tasks answering remote hints, per user.
	private var remoteHintTasks: [String: Task<Void, Never>] = [:]

	/// The users with a remote hint still to answer.
	private var remoteHintPending: Set<String> = []

	#if DEBUG
	/// The number of sync rounds run in answer to remote hints, per user.
	private var remoteHintRoundCounts: [String: Int] = [:]
	#endif

	/// Watches the network path so failed work retries as soon as connectivity returns.
	private var pathMonitor: NWPathMonitor?

	/// Whether the most recent network path report was satisfied.
	private var isNetworkReachable: Bool?

	// MARK: - Initializers
	private init() {}

	// MARK: - Sync
	/// Runs a delta sync across every stream belonging to the given account.
	///
	/// - Parameter userSlug: The user's account slug.
	func syncAll(forUserSlug userSlug: String) async {
		await LibraryOutbox.shared.flush(force: true)
		await self.pull(forUserSlug: userSlug)
	}

	/// Runs a delta sync without flushing the outbox first.
	///
	/// - Parameter userSlug: The user's account slug.
	func pull(forUserSlug userSlug: String) async {
		self.installPathMonitorIfNeeded()
		await self.repairCursorsIfNeeded(forUserSlug: userSlug)

		if let existing = self.inFlight[userSlug] {
			// The in-flight round's delta predates this trigger.
			self.rerunRequested.insert(userSlug)
			await existing.value
			return
		}

		if let throttledUntil = self.throttledUntil[userSlug], throttledUntil > Date() {
			syncLogger.info("THROTTLED skip resumesIn=\(Int(throttledUntil.timeIntervalSinceNow))s")
			return
		}

		let task = Task<Void, Never> { [weak self] in
			guard let self = self else { return }
			await self.runSync(forUserSlug: userSlug)
		}
		self.inFlight[userSlug] = task
		await task.value
		self.inFlight[userSlug] = nil

		#if !os(watchOS)
		await self.refreshLibraryArt(forUserSlug: userSlug)
		await AiringNotificationScheduler.shared.refresh()
		#endif
		await LibrarySyncDiagnostics.logState(forUserSlug: userSlug, reason: "pull")

		if self.rerunRequested.remove(userSlug) != nil {
			await self.pull(forUserSlug: userSlug)
		}
	}

	/// Makes the account's next sync drop its cursors.
	///
	/// - Parameter userSlug: The user's account slug.
	func reconcile(forUserSlug userSlug: String) async {
		syncLogger.notice("RECONCILE")
		self.fullPullRequested.insert(userSlug)
		await self.pull(forUserSlug: userSlug)
	}

	private func runSync(forUserSlug userSlug: String) async {
		// A delta applied now would advance the cursors past state the outbox still owns.
		if await LibraryOutbox.shared.hasPendingOperations(forUserSlug: userSlug) {
			syncLogger.info("DEFER reason=pending-ops")
			return
		}

		if self.fullPullRequested.remove(userSlug) != nil {
			await self.clearCursors(LibrarySyncStream.allCases, forUserSlug: userSlug)
		}

		await LibrarySyncProgress.shared.begin()
		do {
			try await self.pullRounds(forUserSlug: userSlug)
			self.pendingRetries.remove(userSlug)
		} catch {
			syncLogger.error("Sync failed: \(error.librarySyncDescription, privacy: .public)")
			self.pendingRetries.insert(userSlug)

			if let apiError = error as? APIError, apiError.statusCode == 429 {
				self.throttle(userSlug: userSlug, for: apiError.retryAfterInterval ?? self.defaultThrottleInterval)
			}
		}
		await LibrarySyncProgress.shared.end()
	}

	private func pullRounds(forUserSlug userSlug: String) async throws {
		var cursors = await self.readCursors(forUserSlug: userSlug)
		// A pull without an entry cursor carries no tombstones.
		var isFullPull = cursors[.entries] == nil
		var seenEntryIDs: Set<String> = []
		var appliedCount = 0

		while true {
			let response: LibrarySyncResponse
			do {
				response = try await KService
					.librarySync()
					.since(cursors)
					.limit(self.batchLimit)
					.response()
			} catch let error as APIError where error.isCursorExpired {
				syncLogger.notice("A cursor expired. Restarting as a full pull.")
				await self.clearCursors(LibrarySyncStream.allCases, forUserSlug: userSlug)
				cursors = [:]
				appliedCount = 0
				isFullPull = true
				seenEntryIDs = []
				continue
			}

			let relationships = response.data.relationships
			let hasMore = LibrarySyncStream.allCases.contains { response.data.attributes.state(of: $0)?.hasMore == true }
			let roundCount = relationships.entries.count + relationships.trackables.count
			let expectedCount = self.expectedCount(in: response, appliedCount: appliedCount)

			syncLogger.info("PULL entries=\(relationships.entries.count) trackables=\(relationships.trackables.count) episodes=\(relationships.episodes.count) hasMore=\(hasMore)")

			try await self.applyRound(response, forUserSlug: userSlug)

			if isFullPull {
				seenEntryIDs.formUnion(relationships.entries.filter { $0.deletedAt == nil }.map(\.id))
			}

			appliedCount += roundCount
			await LibrarySyncProgress.shared.update(appliedCount: appliedCount, expectedCount: expectedCount)

			#if !os(watchOS)
			var artURLStrings = relationships.trackables.flatMap { [$0.posterURL, $0.bannerURL] }.compactMap(\.self)
			artURLStrings += relationships.episodes.compactMap(\.bannerURL)
			await LibraryArtStore.shared.prefetch(artURLStrings)
			#endif

			cursors = self.advanced(cursors, with: response)

			if !hasMore {
				if isFullPull {
					try await self.sweepEntries(notIn: seenEntryIDs, forUserSlug: userSlug)
				}
				await self.pruneOrphanedTrackables()

				// Force the fraction to exactly 1.0 before ending.
				await LibrarySyncProgress.shared.update(appliedCount: appliedCount, expectedCount: appliedCount)
				break
			}
		}
	}

	/// The number of rows the round expects to apply in total.
	private nonisolated func expectedCount(in response: LibrarySyncResponse, appliedCount: Int) -> Int? {
		let totals = LibrarySyncStream.allCases.compactMap { response.data.attributes.state(of: $0)?.total }
		guard !totals.isEmpty else { return nil }
		return appliedCount + totals.reduce(0, +)
	}

	/// The cursors the next round resumes from.
	private nonisolated func advanced(_ cursors: [LibrarySyncStream: SyncCursor], with response: LibrarySyncResponse) -> [LibrarySyncStream: SyncCursor] {
		var advanced = cursors

		for stream in LibrarySyncStream.allCases {
			guard let state = response.data.attributes.state(of: stream) else { continue }
			advanced[stream] = state.nextSince
		}

		return advanced
	}

	#if !os(watchOS)
	/// Prunes stored art and queues every cached entry's art for download.
	private func refreshLibraryArt(forUserSlug userSlug: String) async {
		var artURLStrings = await MainActor.run {
			LibraryKind.allCases
				.flatMap { kind in
					LibraryStore.shared.entries(forUserSlug: userSlug, kind: kind)
						.flatMap { [$0.trackable?.posterURL, $0.trackable?.bannerURL] }
				}
				.compactMap(\.self)
		}

		artURLStrings += await self.episodeArtURLStrings(forUserSlug: userSlug)

		await LibraryArtStore.shared.prune(keepingURLStrings: Set(artURLStrings))
		await LibraryArtStore.shared.prefetch(artURLStrings)
	}

	/// The art URLs of the account's stored episodes.
	///
	/// - Parameter userSlug: The user's account slug.
	///
	/// - Returns: The episode banner URLs.
	private func episodeArtURLStrings(forUserSlug userSlug: String) async -> [String] {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true

		return await context.perform {
			let request = LocalEpisodeSnapshot.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@ AND bannerURL != nil", userSlug)

			return ((try? context.fetch(request)) ?? []).compactMap(\.bannerURL)
		}
	}
	#endif

	// MARK: - Remote Hints
	/// Answers a hint that the server holds newer state.
	///
	/// - Parameter userSlug: The user's account slug.
	func serverStateAdvanced(forUserSlug userSlug: String) {
		self.remoteHintPending.insert(userSlug)
		guard self.remoteHintTasks[userSlug] == nil else { return }

		self.remoteHintTasks[userSlug] = Task(priority: .utility) { [weak self] in
			guard let self else { return }
			await self.drainRemoteHints(forUserSlug: userSlug)
		}
	}

	/// Waits until every hint received so far has been answered.
	///
	/// - Parameter userSlug: The user's account slug.
	func awaitRemoteHints(forUserSlug userSlug: String) async {
		while let task = self.remoteHintTasks[userSlug] {
			await task.value
		}
	}

	#if DEBUG
	/// The number of sync rounds remote hints have caused for the user since launch.
	///
	/// - Parameter userSlug: The user's account slug.
	func remoteHintRoundCount(forUserSlug userSlug: String) -> Int {
		return self.remoteHintRoundCounts[userSlug] ?? 0
	}
	#endif

	private func drainRemoteHints(forUserSlug userSlug: String) async {
		while self.remoteHintPending.remove(userSlug) != nil {
			await self.syncAll(forUserSlug: userSlug)
			#if DEBUG
			self.remoteHintRoundCounts[userSlug, default: 0] += 1
			#endif

			await MainActor.run {
				NotificationCenter.default.post(name: .KUserStateDidChangeRemotely, object: nil)
			}
		}
		self.remoteHintTasks[userSlug] = nil
	}

	// MARK: - Throttling
	/// The seconds left in the user's throttle window.
	///
	/// - Parameter userSlug: The user's account slug.
	func throttleRemaining(forUserSlug userSlug: String) -> TimeInterval {
		guard let throttledUntil = self.throttledUntil[userSlug] else { return 0 }
		return max(0, throttledUntil.timeIntervalSinceNow)
	}

	/// Pauses the user's sync for the given interval.
	private func throttle(userSlug: String, for interval: TimeInterval) {
		syncLogger.notice("THROTTLED retryAfter=\(interval)")
		self.throttledUntil[userSlug] = Date().addingTimeInterval(interval)
		guard self.throttleRetryTasks[userSlug] == nil else { return }

		self.throttleRetryTasks[userSlug] = Task { [weak self] in
			try? await Task.sleep(nanoseconds: UInt64((interval + 1) * 1_000_000_000))
			guard let self else { return }
			await self.resumeAfterThrottle(forUserSlug: userSlug)
		}
	}

	private func resumeAfterThrottle(forUserSlug userSlug: String) async {
		self.throttleRetryTasks[userSlug] = nil
		await self.syncAll(forUserSlug: userSlug)
	}

	// MARK: - Network Retry
	/// Starts watching the network path on first call.
	private func installPathMonitorIfNeeded() {
		guard self.pathMonitor == nil else { return }

		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { path in
			let isReachable = path.status == .satisfied
			Task { await LibrarySyncEngine.shared.networkPathDidUpdate(isReachable: isReachable) }
		}
		monitor.start(queue: .global(qos: .utility))
		self.pathMonitor = monitor
	}

	/// Records the reported path state and retries pending work when connectivity has just returned.
	///
	/// - Parameter isReachable: Whether the reported path is satisfied.
	private func networkPathDidUpdate(isReachable: Bool) async {
		let wasReachable = self.isNetworkReachable
		self.isNetworkReachable = isReachable

		// Only the return from offline carries a retry signal.
		guard isReachable, wasReachable == false else { return }
		await self.flushAndSyncIfReachable()
	}

	/// Flushes queued mutations and runs a full sync when the device is reachable and work is pending.
	private func flushAndSyncIfReachable() async {
		guard self.isNetworkReachable == true else { return }
		guard let userSlug = User.current?.attributes.slug else { return }

		let hasPendingOperations = await LibraryOutbox.shared.hasPendingOperations(forUserSlug: userSlug)
		guard hasPendingOperations || !self.pendingRetries.isEmpty else { return }

		await self.syncAll(forUserSlug: userSlug)
	}

	// MARK: - Persistence Hops
	// `context.perform`'s async overload keeps the caller's priority and avoids inversion.
	private func readCursors(forUserSlug userSlug: String) async -> [LibrarySyncStream: SyncCursor] {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		return await context.perform {
			var cursors: [LibrarySyncStream: SyncCursor] = [:]

			for stream in LibrarySyncStream.allCases {
				let row = LocalSyncCursor.upsert(forUserSlug: userSlug, stream: stream, in: context)
				cursors[stream] = row.syncCursor
			}

			if context.hasChanges {
				try? context.save()
			}

			return cursors
		}
	}

	private func applyRound(_ response: LibrarySyncResponse, forUserSlug userSlug: String) async throws {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		// Server data is authoritative on constraint collisions.
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		// The cursors must not advance past an unapplied round.
		try await context.perform {
			let relationships = response.data.relationships

			// The catalog lands first.
			for row in relationships.trackables {
				LocalTrackable.apply(row, in: context)
			}

			for row in relationships.entries {
				LocalLibraryEntry.apply(row, userSlug: userSlug, in: context)
			}

			LocalEpisodeSnapshot.replace(with: relationships.episodes, userSlug: userSlug, in: context)

			for stream in LibrarySyncStream.allCases {
				guard let state = response.data.attributes.state(of: stream) else { continue }
				LocalSyncCursor.upsert(forUserSlug: userSlug, stream: stream, in: context).advance(to: state.nextSince)
			}

			if context.hasChanges {
				try context.save()
			}
		}
	}

	/// Drops the trackable cursors while the account's local catalog cannot be trusted.
	///
	/// - Parameter userSlug: The user's account slug.
	private func repairCursorsIfNeeded(forUserSlug userSlug: String) async {
		guard await self.hasEntriesWithoutTrackable(forUserSlug: userSlug) else { return }

		syncLogger.info("REPAIR entries are missing their trackable")

		await self.clearCursors(LibrarySyncStream.allCases.filter { $0.kind != nil }, forUserSlug: userSlug)
	}

	/// Whether an entry points at a trackable the store does not hold.
	///
	/// - Parameter userSlug: The user's account slug.
	///
	/// - Returns: `true` when the local catalog has a hole.
	private func hasEntriesWithoutTrackable(forUserSlug userSlug: String) async -> Bool {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		return await context.perform {
			let request = LocalLibraryEntry.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@ AND trackable == nil", userSlug)
			request.fetchLimit = 1

			return ((try? context.count(for: request)) ?? 0) > 0
		}
	}

	private func clearCursors(_ streams: [LibrarySyncStream], forUserSlug userSlug: String) async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		await context.perform {
			let request = LocalSyncCursor.fetchRequest()
			request.predicate = NSPredicate(
				format: "userSlug == %@ AND stream IN %@",
				userSlug,
				streams.map(\.rawValue)
			)

			do {
				for cursor in try context.fetch(request) {
					context.delete(cursor)
				}
				if context.hasChanges {
					try context.save()
				}
			} catch {
				syncLogger.error("Clear cursors failed: \(error.localizedDescription)")
			}
		}
	}

	/// Deletes the trackables no entry points at.
	private func pruneOrphanedTrackables() async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		await context.perform {
			let request = LocalTrackable.fetchRequest()
			request.predicate = NSPredicate(format: "entries.@count == 0")

			guard let orphaned = try? context.fetch(request), !orphaned.isEmpty else { return }

			for trackable in orphaned {
				context.delete(trackable)
			}

			if context.hasChanges {
				try? context.save()
			}
			syncLogger.info("PRUNE trackables=\(orphaned.count)")
		}
	}

	/// Deletes the account's local rows the full pull never returned.
	private func sweepEntries(notIn seenRemoteIDs: Set<String>, forUserSlug userSlug: String) async throws {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		try await context.perform {
			let operationRequest = LocalOutboxOperation.fetchRequest()
			operationRequest.predicate = NSPredicate(format: "userSlug == %@", userSlug)
			let queuedTrackableIDs = Set(try context.fetch(operationRequest).map(\.trackableID))

			let entryRequest = LocalLibraryEntry.fetchRequest()
			entryRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND NOT (remoteID IN %@)",
				userSlug,
				seenRemoteIDs
			)

			var sweptCount = 0
			for entry in try context.fetch(entryRequest) where !queuedTrackableIDs.contains(entry.trackableID) {
				context.delete(entry)
				sweptCount += 1
			}

			if context.hasChanges {
				try context.save()
			}
			syncLogger.info("SWEEP removed=\(sweptCount)")
		}
	}
}
