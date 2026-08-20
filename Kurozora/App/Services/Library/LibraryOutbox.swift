//
//  LibraryOutbox.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import os.log

private let outboxLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibraryOutbox")

actor LibraryOutbox {
	// MARK: - Properties
	/// The shared `LibraryOutbox` instance.
	static let shared = LibraryOutbox()

	/// The attempt count at which a repeatedly-failing operation is abandoned.
	private let maximumAttemptCount: Int16 = 5

	/// In-flight per-user flush tasks.
	private var inFlight: [String: Task<Void, Never>] = [:]

	/// Users whose in-flight flush runs once more after it finishes.
	private var rerunRequested: Set<String> = []

	/// The earliest time a failing user's next automatic flush attempt may run.
	private var nextAttemptAllowed: [String: Date] = [:]

	/// How a repeated enqueue for the same (user, kind, trackable/target, type) is resolved.
	private enum CoalesceStrategy {
		/// Overwrites the pending operation's payload with the newest value.
		case replace

		/// Cancels the pending operation.
		case cancelOnRepeat
	}

	/// A value snapshot of a pending `LocalOutboxOperation`.
	private struct PendingOutboxOp: Sendable {
		let id: UUID
		let kind: LibraryKind
		let operationType: LibraryOutboxOperationType
		let trackableID: String
		let targetID: String
		let payload: LibraryOutboxPayload?
		let attemptCount: Int16
	}

	// MARK: - Initializers
	private init() {}

	// MARK: - Enqueue
	/// Enqueues a library-status change.
	func enqueueSetStatus(_ status: LibraryStatus, trackableID: String, userSlug: String, kind: LibraryKind, seed: LibraryOutboxSeed?) async {
		await self.cancelPendingOp(type: .remove, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "")

		let payload = LibraryOutboxPayload(statusRaw: status.rawValue)
		await self.persistOp(type: .setStatus, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: payload, seed: seed, coalescing: .replace)

		await LibraryStore.shared.applyStatus(status, forTrackableID: trackableID, userSlug: userSlug, kind: kind, seed: seed)
		self.scheduleFlush()
	}

	/// Enqueues a library removal.
	func enqueueRemove(trackableID: String, userSlug: String, kind: LibraryKind) async {
		await self.cancelAllPendingOps(userSlug: userSlug, kind: kind, trackableID: trackableID)
		await self.persistOp(type: .remove, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: nil, seed: nil, coalescing: .replace)

		await LibraryStore.shared.applyRemoved(forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues a favorite toggle to the given target state.
	func enqueueSetFavorite(_ desired: Bool, trackableID: String, userSlug: String, kind: LibraryKind) async {
		let payload = LibraryOutboxPayload(flag: desired)
		await self.persistOp(type: .setFavorite, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: payload, seed: nil, coalescing: .cancelOnRepeat)

		await LibraryStore.shared.applyFavorite(desired, forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues a reminder toggle to the given target state.
	func enqueueSetReminder(_ desired: Bool, trackableID: String, userSlug: String, kind: LibraryKind) async {
		let payload = LibraryOutboxPayload(flag: desired)
		await self.persistOp(type: .setReminder, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: payload, seed: nil, coalescing: .cancelOnRepeat)

		await LibraryStore.shared.applyReminder(desired, forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues a hidden-status change to the given target state.
	func enqueueSetHidden(_ desired: Bool, trackableID: String, userSlug: String, kind: LibraryKind) async {
		let payload = LibraryOutboxPayload(flag: desired)
		await self.persistOp(type: .setHidden, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: payload, seed: nil, coalescing: .replace)

		await LibraryStore.shared.applyHidden(desired, forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues a rewatch-count change to the given target value.
	func enqueueSetRewatchCount(_ count: Int, trackableID: String, userSlug: String, kind: LibraryKind) async {
		let payload = LibraryOutboxPayload(rewatchCount: count)
		await self.persistOp(type: .setRewatchCount, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: payload, seed: nil, coalescing: .replace)

		await LibraryStore.shared.applyRewatchCount(count, forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues a rating submission.
	func enqueueRate(score: Double, description: String?, trackableID: String, userSlug: String, kind: LibraryKind) async {
		let payload = LibraryOutboxPayload(score: score, reviewDescription: description)
		await self.persistOp(type: .rate, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: payload, seed: nil, coalescing: .replace)

		await LibraryStore.shared.applyRating(score: score, description: description, isSpoiler: nil, recommendation: nil, forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues a rating deletion.
	func enqueueDeleteRating(trackableID: String, userSlug: String, kind: LibraryKind) async {
		await self.persistOp(type: .deleteRating, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: "", payload: nil, seed: nil, coalescing: .replace)

		await LibraryStore.shared.applyRatingRemoved(forTrackableID: trackableID, userSlug: userSlug, kind: kind)
		self.scheduleFlush()
	}

	/// Enqueues an episode watch-status flip.
	func enqueueEpisodeWatchToggle(episodeID: String, userSlug: String) async {
		let currentStatus = await WatchedStore.shared.status(forEpisodeID: episodeID) ?? .notWatched
		let newStatus: WatchStatus = currentStatus == .watched ? .notWatched : .watched

		let payload = LibraryOutboxPayload(watchStatusRaw: newStatus.rawValue)
		await self.persistOp(type: .setEpisodeWatchStatus, userSlug: userSlug, kind: .shows, trackableID: "", targetID: episodeID, payload: payload, seed: nil, coalescing: .cancelOnRepeat)

		await WatchedStore.shared.setStatus(newStatus, forEpisodeID: episodeID)
		self.scheduleFlush()
	}

	/// Enqueues a season watch-status flip and returns the new status.
	@discardableResult
	func enqueueSeasonWatchToggle(seasonID: String, userSlug: String, currentStatus: WatchStatus) async -> WatchStatus {
		let newStatus: WatchStatus = currentStatus == .watched ? .notWatched : .watched

		let payload = LibraryOutboxPayload(watchStatusRaw: newStatus.rawValue)
		await self.persistOp(type: .setSeasonWatchStatus, userSlug: userSlug, kind: .shows, trackableID: "", targetID: seasonID, payload: payload, seed: nil, coalescing: .cancelOnRepeat)

		self.scheduleFlush()
		return newStatus
	}

	// MARK: - Sync guard
	/// Whether any operation is queued for the given account.
	func hasPendingOperations(forUserSlug userSlug: String) async -> Bool {
		return await self.pendingOperationCount(matching: NSPredicate(format: "userSlug == %@", userSlug)) > 0
	}

	/// Whether any operation is queued for the given account and kind.
	func hasPendingOperations(forUserSlug userSlug: String, kind: LibraryKind) async -> Bool {
		return await self.pendingOperationCount(matching: NSPredicate(format: "userSlug == %@ AND kindRaw == %d", userSlug, Int64(kind.rawValue))) > 0
	}

	private func pendingOperationCount(matching predicate: NSPredicate) async -> Int {
		let context = PersistenceController.shared.container.newBackgroundContext()

		return await context.perform {
			let request = LocalOutboxOperation.fetchRequest()
			request.predicate = predicate
			return (try? context.count(for: request)) ?? 0
		}
	}

	// MARK: - Clear
	/// Removes every pending operation for the given account.
	func clear(forUserSlug userSlug: String) async {
		let context = PersistenceController.shared.container.newBackgroundContext()

		await context.perform {
			let request = LocalOutboxOperation.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@", userSlug)
			guard let rows = try? context.fetch(request) else { return }

			for row in rows {
				context.delete(row)
			}
			if context.hasChanges {
				try? context.save()
			}
		}
	}

	// MARK: - Flush
	/// Drains the current user's pending operations to the server.
	///
	/// - Parameter force: Whether to bypass the retry backoff gate.
	func flush(force: Bool = false) async {
		guard let userSlug = User.current?.attributes.slug else { return }
		await self.drain(forUserSlug: userSlug, force: force)
	}

	private func drain(forUserSlug userSlug: String, force: Bool = false) async {
		if let existing = self.inFlight[userSlug] {
			self.rerunRequested.insert(userSlug)
			await existing.value
			return
		}

		if !force, let gate = self.nextAttemptAllowed[userSlug], gate > Date() {
			return
		}

		let task = Task { [weak self] in
			guard let self else { return }
			await self.runDrain(forUserSlug: userSlug)
		}
		self.inFlight[userSlug] = task
		await task.value
		self.inFlight[userSlug] = nil

		if self.rerunRequested.remove(userSlug) != nil {
			await self.drain(forUserSlug: userSlug)
		}
	}

	private func runDrain(forUserSlug userSlug: String) async {
		let ops = await self.fetchPendingOps(forUserSlug: userSlug)
		guard !ops.isEmpty else { return }

		var affectedKinds: Set<LibraryKind> = []
		var maxFailedAttemptCount: Int16 = 0

		for group in Self.consecutiveGroups(ops) {
			guard let kind = group.first?.kind else { continue }
			let label = Self.label(for: group)

			do {
				outboxLogger.info("SEND \(label, privacy: .public)")
				try await self.send(group)
				await self.deleteOps(group)
				affectedKinds.insert(kind)
				outboxLogger.info("OK \(label, privacy: .public)")
			} catch let error as APIError where Self.isClientRejection(error) {
				// The server refused the operation; drop it and leave sync to reconcile.
				outboxLogger.error("REJECT \(label, privacy: .public) msg=\(error.message, privacy: .public)")
				await self.deleteOps(group)
			} catch {
				let nextAttemptCount = (group.map(\.attemptCount).max() ?? 0) + 1
				if nextAttemptCount >= self.maximumAttemptCount {
					outboxLogger.error("ABANDON \(label, privacy: .public) attempts=\(nextAttemptCount)")
					await self.deleteOps(group)
				} else {
					outboxLogger.error("FAIL \(label, privacy: .public) attempt=\(nextAttemptCount) err=\(error.localizedDescription, privacy: .public)")
					await self.markFailed(group, error: error)
					maxFailedAttemptCount = max(maxFailedAttemptCount, nextAttemptCount)
				}
			}
		}

		if maxFailedAttemptCount > 0 {
			self.applyBackoff(forUserSlug: userSlug, attemptCount: maxFailedAttemptCount)
		} else {
			self.nextAttemptAllowed[userSlug] = nil
		}

		for kind in affectedKinds {
			try? await LibrarySyncEngine.shared.sync(kind, forUserSlug: userSlug)
		}
	}

	// MARK: - Transport
	private func send(_ group: [PendingOutboxOp]) async throws {
		guard let first = group.first else { return }
		let kind = first.kind
		let itemIDs = group.map { KurozoraItemID($0.trackableID) }

		switch first.operationType {
		case .setStatus:
			guard let statusRaw = first.payload?.statusRaw, let status = LibraryStatus(rawValue: statusRaw) else { return }
			_ = try await KService.addToLibrary(kind, status: status, itemIDs: itemIDs).response()
		case .remove:
			_ = try await KService.removeFromLibrary(kind, itemIDs: itemIDs).response()
		case .setFavorite:
			_ = try await KService.toggleFavorite(inLibrary: kind, itemIDs: itemIDs).response()
		case .setReminder:
			_ = try await KService.toggleReminder(inLibrary: kind, itemIDs: itemIDs).response()
		case .setHidden:
			guard let flag = first.payload?.flag else { return }
			_ = try await KService.updateInLibrary(kind, itemIDs: itemIDs).hidden(flag).response()
		case .setRewatchCount:
			guard let count = first.payload?.rewatchCount else { return }
			_ = try await KService.updateInLibrary(kind, itemIDs: itemIDs).rewatchCount(count).response()
		case .rate:
			for op in group {
				guard let score = op.payload?.score else { continue }
				try await self.sendRate(kind: kind, trackableID: op.trackableID, score: score, description: op.payload?.reviewDescription)
			}
		case .deleteRating:
			for op in group {
				try await self.sendDeleteRating(kind: kind, trackableID: op.trackableID)
			}
		case .setEpisodeWatchStatus:
			for op in group {
				if let watchStatusRaw = op.payload?.watchStatusRaw, let status = WatchStatus(rawValue: watchStatusRaw) {
					await WatchedStore.shared.setStatus(status, forEpisodeID: op.targetID)
				}
				_ = try await KService.updateWatchStatus(forEpisode: EpisodeIdentity(id: KurozoraItemID(op.targetID))).response()
			}
		case .setSeasonWatchStatus:
			for op in group {
				_ = try await KService.updateWatchStatus(forSeason: SeasonIdentity(id: KurozoraItemID(op.targetID))).response()
			}
		}
	}

	private func sendRate(kind: LibraryKind, trackableID: String, score: Double, description: String?) async throws {
		let itemID = KurozoraItemID(trackableID)
		switch kind {
		case .shows:
			_ = try await KService.rate(ShowIdentity(id: itemID), score: score).description(description).response()
		case .literatures:
			_ = try await KService.rate(LiteratureIdentity(id: itemID), score: score).description(description).response()
		case .games:
			_ = try await KService.rate(GameIdentity(id: itemID), score: score).description(description).response()
		}
	}

	private func sendDeleteRating(kind: LibraryKind, trackableID: String) async throws {
		let itemID = KurozoraItemID(trackableID)
		switch kind {
		case .shows:
			_ = try await KService.deleteRating(ShowIdentity(id: itemID)).response()
		case .literatures:
			_ = try await KService.deleteRating(LiteratureIdentity(id: itemID)).response()
		case .games:
			_ = try await KService.deleteRating(GameIdentity(id: itemID)).response()
		}

		NotificationCenter.default.post(name: .KReviewDidUpdate, object: nil)
	}

	// MARK: - Grouping
	/// Splits FIFO-ordered operations into consecutive runs that a single request can carry.
	private static func consecutiveGroups(_ ops: [PendingOutboxOp]) -> [[PendingOutboxOp]] {
		var groups: [[PendingOutboxOp]] = []

		for op in ops {
			if let first = groups.last?.first, Self.canBatch(first, with: op) {
				groups[groups.count - 1].append(op)
			} else {
				groups.append([op])
			}
		}

		return groups
	}

	/// A compact diagnostic label describing an operation group.
	private static func label(for group: [PendingOutboxOp]) -> String {
		guard let first = group.first else { return "empty" }
		let identities = group.map { $0.trackableID.isEmpty ? $0.targetID : $0.trackableID }.joined(separator: ",")
		return "type=\(first.operationType.rawValue) kind=\(first.kind.rawValue) items=[\(identities)]"
	}

	/// Whether two consecutive operations resolve to the same network request.
	private static func canBatch(_ lhs: PendingOutboxOp, with rhs: PendingOutboxOp) -> Bool {
		guard lhs.kind == rhs.kind, lhs.operationType == rhs.operationType else { return false }

		switch lhs.operationType {
		case .setStatus:
			return lhs.payload?.statusRaw == rhs.payload?.statusRaw
		case .remove:
			return true
		case .setFavorite, .setReminder, .setHidden:
			return lhs.payload?.flag == rhs.payload?.flag
		case .setRewatchCount:
			return lhs.payload?.rewatchCount == rhs.payload?.rewatchCount
		case .rate, .deleteRating, .setEpisodeWatchStatus, .setSeasonWatchStatus:
			return false
		}
	}

	/// Whether the server rejected the operation itself, as opposed to a transient auth or rate-limit failure.
	private static func isClientRejection(_ error: APIError) -> Bool {
		guard let statusCode = error.statusCode else { return false }
		guard (400..<500).contains(statusCode) else { return false }
		return statusCode != 401 && statusCode != 429
	}

	// MARK: - Persistence
	private func persistOp(type: LibraryOutboxOperationType, userSlug: String, kind: LibraryKind, trackableID: String, targetID: String, payload: LibraryOutboxPayload?, seed: LibraryOutboxSeed?, coalescing: CoalesceStrategy) async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

		let identity = trackableID.isEmpty ? targetID : trackableID

		await context.perform {
			let existing = Self.fetchPendingOp(type: type, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: targetID, in: context)

			if let existing {
				switch coalescing {
				case .cancelOnRepeat:
					outboxLogger.info("ENQUEUE-CANCEL type=\(type.rawValue) kind=\(kind.rawValue) item=\(identity, privacy: .public)")
					context.delete(existing)
				case .replace:
					outboxLogger.info("ENQUEUE-REPLACE type=\(type.rawValue) kind=\(kind.rawValue) item=\(identity, privacy: .public)")
					existing.payload = payload.flatMap { try? JSONEncoder().encode($0) }
					if let seed, let encodedSeed = try? JSONEncoder().encode(seed) {
						existing.seed = encodedSeed
					}
				}
			} else {
				outboxLogger.info("ENQUEUE type=\(type.rawValue) kind=\(kind.rawValue) item=\(identity, privacy: .public)")
				let op = LocalOutboxOperation(context: context)
				op.id = UUID()
				op.userSlug = userSlug
				op.kind = kind
				op.trackableID = trackableID
				op.targetID = targetID
				op.operationType = type
				op.payload = payload.flatMap { try? JSONEncoder().encode($0) }
				op.seed = seed.flatMap { try? JSONEncoder().encode($0) }
				op.createdAt = Date()
				op.attemptCount = 0
			}

			if context.hasChanges {
				do {
					try context.save()
				} catch {
					outboxLogger.error("Failed to persist outbox operation: \(error.localizedDescription)")
				}
			}
		}
	}

	private func cancelPendingOp(type: LibraryOutboxOperationType, userSlug: String, kind: LibraryKind, trackableID: String, targetID: String) async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true

		await context.perform {
			guard let existing = Self.fetchPendingOp(type: type, userSlug: userSlug, kind: kind, trackableID: trackableID, targetID: targetID, in: context) else { return }
			context.delete(existing)
			if context.hasChanges {
				try? context.save()
			}
		}
	}

	private func cancelAllPendingOps(userSlug: String, kind: LibraryKind, trackableID: String) async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true

		await context.perform {
			let request = LocalOutboxOperation.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@ AND kindRaw == %d AND trackableID == %@", userSlug, Int64(kind.rawValue), trackableID)
			guard let rows = try? context.fetch(request) else { return }

			for row in rows {
				context.delete(row)
			}
			if context.hasChanges {
				try? context.save()
			}
		}
	}

	private func fetchPendingOps(forUserSlug userSlug: String) async -> [PendingOutboxOp] {
		let context = PersistenceController.shared.container.newBackgroundContext()

		return await context.perform {
			let request = LocalOutboxOperation.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@", userSlug)
			request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
			let rows = (try? context.fetch(request)) ?? []
			return rows.map { row in
				PendingOutboxOp(
					id: row.id,
					kind: row.kind,
					operationType: row.operationType,
					trackableID: row.trackableID,
					targetID: row.targetID,
					payload: row.decodedPayload,
					attemptCount: row.attemptCount
				)
			}
		}
	}

	private func deleteOps(_ ops: [PendingOutboxOp]) async {
		guard !ops.isEmpty else { return }
		let ids = ops.map(\.id)
		let context = PersistenceController.shared.container.newBackgroundContext()

		await context.perform {
			let request = LocalOutboxOperation.fetchRequest()
			request.predicate = NSPredicate(format: "id IN %@", ids)
			guard let rows = try? context.fetch(request) else { return }

			for row in rows {
				context.delete(row)
			}
			if context.hasChanges {
				try? context.save()
			}
		}
	}

	private func markFailed(_ ops: [PendingOutboxOp], error: Error) async {
		guard !ops.isEmpty else { return }
		let ids = ops.map(\.id)
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true

		await context.perform {
			let request = LocalOutboxOperation.fetchRequest()
			request.predicate = NSPredicate(format: "id IN %@", ids)
			guard let rows = try? context.fetch(request) else { return }

			let now = Date()
			for row in rows {
				row.attemptCount += 1
				row.lastAttemptAt = now
				row.lastError = error.localizedDescription
			}
			if context.hasChanges {
				try? context.save()
			}
		}
	}

	private static func fetchPendingOp(type: LibraryOutboxOperationType, userSlug: String, kind: LibraryKind, trackableID: String, targetID: String, in context: NSManagedObjectContext) -> LocalOutboxOperation? {
		let request = LocalOutboxOperation.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d AND trackableID == %@ AND targetID == %@ AND operationTypeRaw == %d",
			userSlug,
			Int64(kind.rawValue),
			trackableID,
			targetID,
			Int64(type.rawValue)
		)
		request.fetchLimit = 1
		return try? context.fetch(request).first
	}

	// MARK: - Backoff
	private func applyBackoff(forUserSlug userSlug: String, attemptCount: Int16) {
		let seconds = min(pow(2.0, Double(attemptCount)), 3600.0)
		self.nextAttemptAllowed[userSlug] = Date().addingTimeInterval(seconds)
	}

	private func scheduleFlush() {
		Task { await self.flush() }
	}
}
