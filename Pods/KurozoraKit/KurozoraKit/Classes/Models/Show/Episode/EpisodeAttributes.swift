//
//  EpisodeAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Episode {
	/**
		A root object that stores information about a single episode, such as the episodes's number, name, and air date.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The link to a poster image of the episode.
		public let poster: Media?

		/// The link to a banner image of the episode.
		public let banner: Media?

		/// The in season number of the episode.
		public let number: Int

		/// The total number of the episode.
		public let numberTotal: Int

		/// The title of the episodes.
		public let title: String

		/// The duration of the episode.
		public let duration: String

		/// The stats of the episode.
		public let stats: MediaStat?

		/// The air date of the episode.
		public let firstAired: Date?

		/// The synopsis text of the episode.
		public let synopsis: String?

		/// Whether the episode is a filler.
		public let isFiller: Bool

		/// Whether the episode details have been verified.
		public let isVerified: Bool

		// Authenticated Attirbutes
		/// The rating given by the authenticated user.
		public var givenRating: Double?

		/// Whether the authenticated user has watched the episode.
		fileprivate let isWatched: Bool?

		/// The watch status of the episode for the authenticated user.
		fileprivate var _watchStatus: WatchStatus?
	}
}

// MARK: - Helpers
extension Episode.Attributes {
	// MARK: - Properties
	/// The watch status of the episode.
	public var watchStatus: WatchStatus? {
		get {
			return self._watchStatus ?? WatchStatus(self.isWatched)
		}
		set {
			self._watchStatus = newValue
		}
	}

	// MARK: - Functions
	/**
		Updates the attributes with the given `WatchStatus` object.

		- Parameter watchStatus: The `WatchStatus` object used to update the attributes.
	*/
	public mutating func update(using watchStatus: WatchStatus) {
		self.watchStatus = watchStatus
	}

	/**
		Returns a copy of the object with the updated attributes from the given `WatchStatus` object.

		- Parameter watchStatus: The `WatchStatus` object used to update the attributes.

		- Returns: a copy of the object with the updated attributes from the given `WatchStatus` object.
	*/
	public mutating func updated(using watchStatus: WatchStatus) -> Self {
		var episodeAttributes = self
		episodeAttributes.watchStatus = watchStatus
		return episodeAttributes
	}
}
