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

/// Drives the combined library delta sync into the local store.
actor LibrarySyncEngine {
	// MARK: - Properties
	/// Returns the singleton `LibrarySyncEngine` instance.
	static let shared = LibrarySyncEngine()

	/// The maximum number of rows requested per batch.
	private let batchLimit = 500

	/// In-flight per-`(userSlug, kind)` sync tasks, used to dedupe concurrent callers.
	private var inFlight: [String: Task<Void, Error>] = [:]

	/// Keys whose in-flight sync runs once more after it finishes.
	private var rerunRequested: Set<String> = []

	/// In-flight `syncAll` tasks, keyed by `userSlug`, used to dedupe overlapping calls
	/// from concurrent lifecycle triggers.
	private var syncAllInFlight: [String: Task<Void, Never>] = [:]

	/// Users whose in-flight `syncAll` runs once more after it finishes.
	private var syncAllRerunRequested: Set<String> = []

	/// Kinds that failed on the last attempt and should be retried when the network
	/// becomes reachable again. Keyed by `(userSlug, kind)`.
	private var pendingRetries: Set<String> = []

	/// Keys whose next sync drops the cursor first.
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
	/// Runs a delta sync for every library kind belonging to the given account.
	///
	/// - Parameter userSlug: The user's account slug.
	func syncAll(forUserSlug userSlug: String) async {
		self.installPathMonitorIfNeeded()
		await self.repairCursorsIfNeeded(forUserSlug: userSlug)
		await LibraryOutbox.shared.flush(force: true)

		if let existing = self.syncAllInFlight[userSlug] {
			// The in-flight round's delta predates this trigger.
			self.syncAllRerunRequested.insert(userSlug)
			await existing.value
			return
		}

		let task = Task<Void, Never> { [weak self] in
			guard let self = self else { return }
			for kind in LibraryKind.allCases {
				do {
					try await self.sync(kind, forUserSlug: userSlug)
				} catch {
					syncLogger.error("\(kind.stringValue) sync failed: \(error.librarySyncDescription, privacy: .public)")
				}
			}
		}
		self.syncAllInFlight[userSlug] = task
		await task.value
		self.syncAllInFlight[userSlug] = nil

		#if !os(watchOS)
		await self.refreshLibraryArt(forUserSlug: userSlug)
		#endif
		await LibrarySyncDiagnostics.logState(forUserSlug: userSlug, reason: "syncAll")

		if self.syncAllRerunRequested.remove(userSlug) != nil {
			await self.syncAll(forUserSlug: userSlug)
		}
	}

	#if !os(watchOS)
	/// Prunes stored art for removed entries and queues every cached entry's
	/// poster and banner for download.
	private func refreshLibraryArt(forUserSlug userSlug: String) async {
		let artURLStrings = await MainActor.run {
			LibraryKind.allCases
				.flatMap { kind in
					LibraryStore.shared.entries(forUserSlug: userSlug, kind: kind)
						.flatMap { [$0.trackable?.posterURL, $0.trackable?.bannerURL] }
				}
				.compactMap(\.self)
		}

		await LibraryArtStore.shared.prune(keepingURLStrings: Set(artURLStrings))
		await LibraryArtStore.shared.prefetch(artURLStrings)
	}
	#endif

	/// Runs a delta sync for the given library kind, looping until the server reports
	/// no more rows past the current cursor.
	///
	/// - Parameters:
	///    - kind: The library kind to sync.
	///    - userSlug: The user's account slug.
	func sync(_ kind: LibraryKind, forUserSlug userSlug: String) async throws {
		self.installPathMonitorIfNeeded()

		if let throttledUntil = self.throttledUntil[userSlug], throttledUntil > Date() {
			syncLogger.info("THROTTLED skip kind=\(kind.rawValue) resumesIn=\(Int(throttledUntil.timeIntervalSinceNow))s")
			return
		}

		let key = self.coalesceKey(userSlug: userSlug, kind: kind)
		if let existing = self.inFlight[key] {
			// The in-flight round's delta predates this trigger.
			self.rerunRequested.insert(key)
			try await existing.value
			return
		}

		let task = Task { [weak self] in
			guard let self = self else { return }
			try await self.runSync(kind, forUserSlug: userSlug)
		}
		self.inFlight[key] = task
		do {
			try await task.value
			self.inFlight[key] = nil
			self.pendingRetries.remove(key)
		} catch {
			self.inFlight[key] = nil
			self.rerunRequested.remove(key)
			self.pendingRetries.insert(key)
			if let apiError = error as? APIError, apiError.statusCode == 429 {
				self.throttle(userSlug: userSlug, for: apiError.retryAfterInterval ?? self.defaultThrottleInterval)
			}
			throw error
		}

		if self.rerunRequested.remove(key) != nil {
			try await self.sync(kind, forUserSlug: userSlug)
		}
	}

	/// Makes the kind's next sync drop its cursor.
	///
	/// - Parameters:
	///    - kind: The library kind to reconcile.
	///    - userSlug: The user's account slug.
	func reconcile(_ kind: LibraryKind, forUserSlug userSlug: String) async throws {
		syncLogger.notice("RECONCILE kind=\(kind.rawValue)")
		self.fullPullRequested.insert(self.coalesceKey(userSlug: userSlug, kind: kind))
		try await self.sync(kind, forUserSlug: userSlug)
	}

	private func runSync(_ kind: LibraryKind, forUserSlug userSlug: String) async throws {
		// A kind with unflushed mutations is not reconciled with the server; applying a
		// delta now would advance the cursor past state the outbox still owns.
		if await LibraryOutbox.shared.hasPendingOperations(forUserSlug: userSlug, kind: kind) {
			syncLogger.info("DEFER kind=\(kind.rawValue) reason=pending-ops")
			return
		}

		if self.fullPullRequested.remove(self.coalesceKey(userSlug: userSlug, kind: kind)) != nil {
			await self.clearCursor(forUserSlug: userSlug, kind: kind)
		}

		await LibrarySyncProgress.shared.begin(kind)
		do {
			try await self.pullBatches(kind, forUserSlug: userSlug)
			await LibrarySyncProgress.shared.end(kind)
		} catch {
			await LibrarySyncProgress.shared.end(kind)
			throw error
		}
	}

	private func pullBatches(_ kind: LibraryKind, forUserSlug userSlug: String) async throws {
		var appliedCount = 0
		// A pull without a cursor carries no tombstones, so the rows it never mentions are
		// swept at the end instead of being deleted up front.
		var isFullPull = await self.readCursor(forUserSlug: userSlug, kind: kind) == nil
		var seenRemoteIDs: Set<String> = []

		while true {
			let cursor = await self.readCursor(forUserSlug: userSlug, kind: kind)

			let response: LibrarySyncResponse
			do {
				response = try await KService
					.librarySync(kind)
					.since(cursor)
					.limit(self.batchLimit)
					.response()
			} catch let error as APIError where error.isCursorExpired {
				syncLogger.notice("Cursor expired for \(kind.stringValue); restarting as a full pull.")
				await self.clearCursor(forUserSlug: userSlug, kind: kind)
				appliedCount = 0
				isFullPull = true
				seenRemoteIDs = []
				continue
			}

			let batch = response.data.relationships.libraries
			let nextSince = response.data.attributes.nextSince
			let hasMore = response.data.attributes.hasMore
			// `total` counts the rows past the requested cursor, including this batch.
			let expectedCount = response.data.attributes.total.map { appliedCount + $0 }
			await LibrarySyncProgress.shared.update(kind, appliedCount: appliedCount, expectedCount: expectedCount)

			syncLogger.info("PULL kind=\(kind.rawValue) since=\(cursor?.updatedAt ?? "nil") batch=\(batch.count) hasMore=\(hasMore) next=\(nextSince?.updatedAt ?? "nil")")

			try await self.applyBatch(batch, nextSince: nextSince, forUserSlug: userSlug, kind: kind)

			if isFullPull {
				seenRemoteIDs.formUnion(batch.filter { $0.deletedAt == nil }.map(\.id))
			}

			appliedCount += batch.count
			await LibrarySyncProgress.shared.update(kind, appliedCount: appliedCount, expectedCount: expectedCount)

			#if !os(watchOS)
			let artURLStrings = batch.filter { $0.deletedAt == nil }.flatMap { [$0.posterURL, $0.bannerURL] }.compactMap(\.self)
			await LibraryArtStore.shared.prefetch(artURLStrings)
			#endif

			if !hasMore {
				if isFullPull {
					try await self.sweepEntries(notIn: seenRemoteIDs, forUserSlug: userSlug, kind: kind)
				}

				// Force the fraction to exactly 1.0 before ending.
				await LibrarySyncProgress.shared.update(kind, appliedCount: appliedCount, expectedCount: appliedCount)
				break
			}
		}
	}

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
	/// Starts watching the network path on first call. Idempotent.
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

		// The monitor also reports on start and on every route change while online. Only
		// the return from offline carries a retry signal.
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
	private func readCursor(forUserSlug userSlug: String, kind: LibraryKind) async -> SyncCursor? {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		return await context.perform {
			let row = LocalSyncCursor.upsert(forUserSlug: userSlug, kind: kind, in: context)
			if context.hasChanges {
				try? context.save()
			}
			return row.syncCursor
		}
	}

	private func applyBatch(_ batch: [LibrarySyncEntry], nextSince: SyncCursor?, forUserSlug userSlug: String, kind: LibraryKind) async throws {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		// Server data is authoritative on constraint collisions.
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		// Rethrow save failures — the cursor must not advance past an unapplied batch.
		try await context.perform {
			for row in batch {
				LocalLibraryEntry.apply(row, userSlug: userSlug, kind: kind, in: context)
			}

			let cursorRow = LocalSyncCursor.upsert(forUserSlug: userSlug, kind: kind, in: context)
			cursorRow.advance(to: nextSince)

			if context.hasChanges {
				try context.save()
			}
		}
	}

	/// Drops every cursor while the account's local rows cannot be trusted.
	///
	/// - Parameter userSlug: The user's account slug.
	private func repairCursorsIfNeeded(forUserSlug userSlug: String) async {
		guard let reason = await self.fullPullReason(forUserSlug: userSlug) else { return }

		syncLogger.info("REPAIR pulling the full library, \(reason, privacy: .public)")

		for kind in LibraryKind.allCases {
			await self.clearCursor(forUserSlug: userSlug, kind: kind)
		}
	}

	/// Reports what makes the account's local rows untrustworthy.
	///
	/// - Parameter userSlug: The user's account slug.
	///
	/// - Returns: The reason a full pull is due.
	private func fullPullReason(forUserSlug userSlug: String) async -> String? {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		return await context.perform {
			let entryRequest = LocalLibraryEntry.fetchRequest()
			entryRequest.predicate = NSPredicate(format: "userSlug == %@ AND trackable == nil", userSlug)
			entryRequest.fetchLimit = 1

			if ((try? context.count(for: entryRequest)) ?? 0) > 0 {
				return "entries are missing their trackable"
			}

			let cursorRequest = LocalSyncCursor.fetchRequest()
			cursorRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND payloadVersion != %d",
				userSlug,
				LocalSyncCursor.currentPayloadVersion
			)
			cursorRequest.fetchLimit = 1

			if ((try? context.count(for: cursorRequest)) ?? 0) > 0 {
				return "the sync payload shape changed"
			}

			return nil
		}
	}

	private func clearCursor(forUserSlug userSlug: String, kind: LibraryKind) async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		await context.perform {
			let cursorRequest = LocalSyncCursor.fetchRequest()
			cursorRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d",
				userSlug,
				Int64(kind.rawValue)
			)

			do {
				for cursor in try context.fetch(cursorRequest) {
					context.delete(cursor)
				}
				if context.hasChanges {
					try context.save()
				}
			} catch {
				syncLogger.error("Clear cursor failed: \(error.localizedDescription)")
			}
		}
	}

	/// Deletes the kind's local rows the full pull never returned.
	private func sweepEntries(notIn seenRemoteIDs: Set<String>, forUserSlug userSlug: String, kind: LibraryKind) async throws {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		try await context.perform {
			let operationRequest = LocalOutboxOperation.fetchRequest()
			operationRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d",
				userSlug,
				Int64(kind.rawValue)
			)
			let queuedTrackableIDs = Set(try context.fetch(operationRequest).map(\.trackableID))

			let entryRequest = LocalLibraryEntry.fetchRequest()
			entryRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d AND NOT (remoteID IN %@)",
				userSlug,
				Int64(kind.rawValue),
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
			syncLogger.info("SWEEP kind=\(kind.rawValue) removed=\(sweptCount)")
		}
	}

	// MARK: - Helpers
	private nonisolated func coalesceKey(userSlug: String, kind: LibraryKind) -> String {
		return "\(userSlug)::\(kind.rawValue)"
	}
}
