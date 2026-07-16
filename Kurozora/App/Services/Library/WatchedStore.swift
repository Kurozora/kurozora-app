//
//  WatchedStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

/// In-memory session cache of the authenticated user's episode watch statuses.
@MainActor
final class WatchedStore {
	// MARK: - Properties
	/// Returns the singleton `WatchedStore` instance.
	static let shared = WatchedStore()

	/// Watch statuses keyed by episode identifier.
	private var statuses: [String: WatchStatus] = [:]

	/// Entity tags for previously fetched overlay id sets.
	private var overlayETags: [String: String] = [:]

	// MARK: - Initializers
	private init() {}

	// MARK: - Read
	/// Returns the cached watch status for the given episode.
	///
	/// - Parameter episodeID: The identifier of the episode.
	///
	/// - Returns: The cached watch status.
	func status(forEpisodeID episodeID: String) -> WatchStatus? {
		return self.statuses[episodeID]
	}

	// MARK: - Write
	/// Records the watch status for the given episode.
	///
	/// - Parameters:
	///    - status: The watch status reported by the server.
	///    - episodeID: The identifier of the episode.
	func setStatus(_ status: WatchStatus, forEpisodeID episodeID: String) {
		self.statuses[episodeID] = status
	}

	/// Records every entry of a watched overlay response.
	///
	/// - Parameters:
	///    - entries: The entries from a `WatchedOverlayResponse`.
	///    - requestedIDs: The episode identifiers the overlay was requested for.
	func apply(_ entries: [WatchedOverlayEntry], requestedIDs: [String]) {
		var watchedIDs: Set<String> = []

		for entry in entries {
			guard let episodeID = entry.relationships.episodes.data.first?.id.rawValue else { continue }
			watchedIDs.insert(episodeID)
			self.statuses[episodeID] = .watched
		}

		for episodeID in requestedIDs where !watchedIDs.contains(episodeID) {
			self.statuses[episodeID] = .notWatched
		}
	}

	// MARK: - Entity Tags
	/// Returns the entity tag recorded for the given overlay id set.
	///
	/// - Parameter requestedIDs: The episode identifiers the overlay covers.
	///
	/// - Returns: The recorded entity tag.
	func etag(forRequestedIDs requestedIDs: [String]) -> String? {
		return self.overlayETags[Self.etagKey(forRequestedIDs: requestedIDs)]
	}

	/// Records the entity tag for the given overlay id set.
	///
	/// - Parameters:
	///    - etag: The entity tag reported by the server.
	///    - requestedIDs: The episode identifiers the overlay covers.
	func setETag(_ etag: String?, forRequestedIDs requestedIDs: [String]) {
		self.overlayETags[Self.etagKey(forRequestedIDs: requestedIDs)] = etag
	}

	private static func etagKey(forRequestedIDs requestedIDs: [String]) -> String {
		return requestedIDs.sorted().joined(separator: ",")
	}

	// MARK: - Delete
	/// Removes every cached status and entity tag.
	func clear() {
		self.statuses.removeAll()
		self.overlayETags.removeAll()
	}
}
