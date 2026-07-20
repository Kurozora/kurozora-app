//
//  LibrarySyncEngine.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import os.log
import Reachability
import UIKit

private let syncLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibrarySyncEngine")

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

	/// Tracks whether the reachability bridge has been installed once.
	private var reachabilityBridgeInstalled = false

	// MARK: - Initializers
	private init() {}

	// MARK: - Sync
	/// Runs a delta sync for every library kind belonging to the given account.
	///
	/// - Parameter userSlug: The user's account slug.
	func syncAll(forUserSlug userSlug: String) async {
		self.installReachabilityBridgeIfNeeded()

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
					syncLogger.error("\(kind.stringValue) sync failed: \(error.localizedDescription)")
				}
			}
		}
		self.syncAllInFlight[userSlug] = task
		await task.value
		self.syncAllInFlight[userSlug] = nil

		await self.refreshLibraryArt(forUserSlug: userSlug)

		if self.syncAllRerunRequested.remove(userSlug) != nil {
			await self.syncAll(forUserSlug: userSlug)
		}
	}

	/// Prunes stored art for removed entries and queues every cached entry's
	/// poster and banner for download.
	private func refreshLibraryArt(forUserSlug userSlug: String) async {
		let artURLStrings = await MainActor.run {
			LibraryKind.allCases
				.flatMap { kind in
					LibraryStore.shared.entries(forUserSlug: userSlug, kind: kind)
						.flatMap { [$0.posterURL, $0.bannerURL] }
				}
				.compactMap(\.self)
		}

		await LibraryArtStore.shared.prune(keepingURLStrings: Set(artURLStrings))
		await LibraryArtStore.shared.prefetch(artURLStrings)
	}

	/// Runs a delta sync for the given library kind, looping until the server reports
	/// no more rows past the current cursor.
	///
	/// - Parameters:
	///    - kind: The library kind to sync.
	///    - userSlug: The user's account slug.
	func sync(_ kind: LibraryKind, forUserSlug userSlug: String) async throws {
		self.installReachabilityBridgeIfNeeded()

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
			throw error
		}

		if self.rerunRequested.remove(key) != nil {
			try await self.sync(kind, forUserSlug: userSlug)
		}
	}

	private func runSync(_ kind: LibraryKind, forUserSlug userSlug: String) async throws {
		// Initial sync carries no tombstones; the local slice must start empty.
		if await self.readCursor(forUserSlug: userSlug, kind: kind) == nil {
			await self.resetLocalState(forUserSlug: userSlug, kind: kind)
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
				syncLogger.notice("Cursor expired for \(kind.stringValue); restarting initial sync.")
				await self.resetLocalState(forUserSlug: userSlug, kind: kind)
				appliedCount = 0
				continue
			}

			let batch = response.data.relationships.libraries
			let nextSince = response.data.attributes.nextSince
			let hasMore = response.data.attributes.hasMore
			// `total` counts the rows past the requested cursor, including this batch.
			let expectedCount = response.data.attributes.total.map { appliedCount + $0 }
			await LibrarySyncProgress.shared.update(kind, appliedCount: appliedCount, expectedCount: expectedCount)

			try await self.applyBatch(batch, nextSince: nextSince, forUserSlug: userSlug, kind: kind)

			appliedCount += batch.count
			await LibrarySyncProgress.shared.update(kind, appliedCount: appliedCount, expectedCount: expectedCount)

			let artURLStrings = batch.filter { $0.deletedAt == nil }.flatMap { [$0.posterURL, $0.bannerURL] }.compactMap(\.self)
			await LibraryArtStore.shared.prefetch(artURLStrings)

			if !hasMore {
				// Force the fraction to exactly 1.0 before ending.
				await LibrarySyncProgress.shared.update(kind, appliedCount: appliedCount, expectedCount: appliedCount)
				break
			}
		}
	}

	// MARK: - Reachability Retry
	/// Hooks the reachability notification on first call. Idempotent.
	private func installReachabilityBridgeIfNeeded() {
		guard !self.reachabilityBridgeInstalled else { return }
		self.reachabilityBridgeInstalled = true
		NotificationCenter.default.addObserver(
			forName: .reachabilityChanged,
			object: nil,
			queue: nil
		) { _ in
			Task { await LibrarySyncEngine.shared.retryPendingIfReachable() }
		}
	}

	/// Re-attempts every `(userSlug, kind)` that failed since the last successful run,
	/// provided the device is currently reachable.
	private func retryPendingIfReachable() async {
		guard !self.pendingRetries.isEmpty else { return }
		guard KNetworkManager.shared.reachability?.connection != .unavailable else { return }

		for key in self.pendingRetries {
			guard let (userSlug, kind) = self.split(key: key) else { continue }
			do {
				try await self.sync(kind, forUserSlug: userSlug)
			} catch {
				syncLogger.error("Retry for \(kind.stringValue) failed: \(error.localizedDescription)")
			}
		}
	}

	// MARK: - Persistence Hops
	// `context.perform`'s async overload keeps the caller's priority and avoids inversion.
	private func readCursor(forUserSlug userSlug: String, kind: LibraryKind) async -> SyncCursor? {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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

	private func resetLocalState(forUserSlug userSlug: String, kind: LibraryKind) async {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		await context.perform {
			let entryRequest = LocalLibraryEntry.fetchRequest()
			entryRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d",
				userSlug,
				Int64(kind.rawValue)
			)

			let cursorRequest = LocalSyncCursor.fetchRequest()
			cursorRequest.predicate = NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d",
				userSlug,
				Int64(kind.rawValue)
			)

			do {
				for entry in try context.fetch(entryRequest) {
					context.delete(entry)
				}
				for cursor in try context.fetch(cursorRequest) {
					context.delete(cursor)
				}
				if context.hasChanges {
					try context.save()
				}
			} catch {
				syncLogger.error("Reset local state failed: \(error.localizedDescription)")
			}
		}
	}

	// MARK: - Helpers
	private nonisolated func coalesceKey(userSlug: String, kind: LibraryKind) -> String {
		return "\(userSlug)::\(kind.rawValue)"
	}

	private nonisolated func split(key: String) -> (String, LibraryKind)? {
		let parts = key.split(separator: ":", omittingEmptySubsequences: false).map(String.init)
		guard parts.count >= 3, let rawKind = Int(parts.last ?? ""), let kind = LibraryKind(rawValue: rawKind) else {
			return nil
		}
		let userSlug = parts.dropLast(2).joined(separator: ":")
		return (userSlug, kind)
	}

}
