//
//  SeasonUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/09/2023.
//

/// A root object that stores information about an season update resource.
public struct SeasonUpdate: Codable, Sendable {
	// MARK: - Properties
	/// Whether the season is watched.
	public let isWatched: Bool
}

// MARK: - Helpers
extension SeasonUpdate {
	// MARK: - Properties
	/// The watch status of the season.
	public var watchStatus: WatchStatus {
		return WatchStatus(self.isWatched)
	}
}
