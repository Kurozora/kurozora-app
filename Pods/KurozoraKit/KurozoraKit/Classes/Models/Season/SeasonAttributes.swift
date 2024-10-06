//
//  SeasonAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Season {
	/// A root object that stores information about a single season, such as the season's title, number, and episodes count.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The link to a poster of the season.
		public let poster: Media?

		/// The number of the season.
		public let number: Int

		/// The title of the season.
		public let title: String

		/// The synopsis of the season.
		public let synopsis: String?

		/// The episode count of the season.
		public let episodeCount: Int

		/// The average of all episode ratings.
		public let ratingAverage: Double

		/// The premiere date of the season.
		public let startedAt: Date?

		/// Whether the authenticated user has watched the episode.
		fileprivate let isWatched: Bool?

		/// The watch status of the episode for the authenticated user.
		fileprivate var _watchStatus: WatchStatus?
	}
}

// MARK: - Helpers
extension Season.Attributes {
	// MARK: - Properties
	/// The watch status of the season.
	public var watchStatus: WatchStatus? {
		get {
			return self._watchStatus ?? WatchStatus(self.isWatched)
		}
		set {
			self._watchStatus = newValue
		}
	}

	// MARK: - Functions
	/// Updates the attributes with the given `WatchStatus` object.
	///
	/// - Parameter watchStatus: The `WatchStatus` object used to update the attributes.
	public mutating func update(using watchStatus: WatchStatus) {
		self.watchStatus = watchStatus
	}

	/// Returns a copy of the object with the updated attributes from the given `WatchStatus` object.
	///
	/// - Parameter watchStatus: The `WatchStatus` object used to update the attributes.
	///
	/// - Returns: a copy of the object with the updated attributes from the given `WatchStatus` object.
	public mutating func updated(using watchStatus: WatchStatus) -> Self {
		var seasonAttributes = self
		seasonAttributes.watchStatus = watchStatus
		return seasonAttributes
	}
}
