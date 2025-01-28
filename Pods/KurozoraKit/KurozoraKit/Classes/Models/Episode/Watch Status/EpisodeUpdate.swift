//
//  EpisodeUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 31/01/2020.
//

/// A root object that stores information about an episode update resource.
public struct EpisodeUpdate: Codable, Sendable {
	// MARK: - Properties
	/// Whether the episode is watched.
	public let isWatched: Bool
}

// MARK: - Helpers
extension EpisodeUpdate {
	// MARK: - Properties
	/// The watch status of the episode.
	public var watchStatus: WatchStatus {
		return WatchStatus(self.isWatched)
	}
}
