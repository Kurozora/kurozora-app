//
//  UpNextViewModel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import Observation

@MainActor @Observable
final class UpNextViewModel {
	// MARK: - Properties
	var loadState: LoadState = .idle
	var episodes: [Episode] = []

	/// The episodes with an in-flight watch status request.
	private var pendingEpisodeIDs: Set<KurozoraItemID> = []

	private var hasFetchedOnce = false

	// MARK: - Functions
	func fetchIfNeeded() async {
		guard !self.hasFetchedOnce else { return }
		await self.fetchUpNext()
	}

	func refresh() async {
		self.hasFetchedOnce = false
		await self.fetchUpNext()
	}

	/// Returns whether the episode has a watch status request in flight.
	///
	/// - Parameter episode: The episode to check.
	///
	/// - Returns: `true` while the request is running.
	func isPending(_ episode: Episode) -> Bool {
		return self.pendingEpisodeIDs.contains(episode.id)
	}

	/// Toggles the episode's watch status and rebuilds the queue.
	///
	/// - Parameter episode: The episode whose watch status to flip.
	///
	/// - Returns: The episode's watch status as the server reports it.
	@discardableResult
	func markAsWatched(_ episode: Episode) async -> Bool? {
		guard !self.pendingEpisodeIDs.contains(episode.id) else { return nil }

		self.pendingEpisodeIDs.insert(episode.id)
		defer { self.pendingEpisodeIDs.remove(episode.id) }

		do {
			let identity = EpisodeIdentity(id: episode.id)
			let response = try await KService.updateWatchStatus(forEpisode: identity).response()

			// The queue is replaced in one pass once the server has recomputed it. Removing
			// the row first would show the list settle twice.
			await self.reloadQueue()

			WatchSessionManager.shared.notifyUpNextDidChange()

			return response.data.isWatched
		} catch {
			print("Up Next watch status update failed:", error.localizedDescription)
			return nil
		}
	}

	/// Refreshes the queue in place, leaving the load state alone so no spinner appears.
	func reloadQueue() async {
		do {
			self.episodes = try await self.fetchQueue()
		} catch {
			print("Up Next reload failed:", error.localizedDescription)
		}
	}

	// MARK: - Private
	private func fetchUpNext() async {
		self.hasFetchedOnce = true
		self.loadState = .loading

		do {
			self.episodes = try await self.fetchQueue()
			self.loadState = .loaded
		} catch {
			self.hasFetchedOnce = false
			self.loadState = .error(L10n.failedToLoadUpNext)
			print("Up Next fetch error:", error.localizedDescription)
		}
	}

	private func fetchQueue() async throws -> [Episode] {
		let identities = try await KService.upNextEpisodes().limit(25).response().data

		guard !identities.isEmpty else { return [] }

		let episodes = try await KService.details(identities).response().data

		// The batch detail request gives no ordering guarantee, so the queue is rebuilt
		// in the order the server returned the identities.
		let episodesByID = Dictionary(episodes.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

		return identities.compactMap { episodesByID[$0.id] }
	}
}
