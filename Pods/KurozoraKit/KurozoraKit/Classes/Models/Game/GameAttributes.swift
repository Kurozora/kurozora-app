//
//  GameAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

extension Game {
	/// A root object that stores information about a single game, such as the game's title, episode count, and air date.
	public struct Attributes: Codable {
		// MARK: - Properties
		// General
		/// The IGDB id of the game.
		public let igdbID: Int?

		/// The IGDB slug of the game.
		public let igdbSlug: String?

		/// The slug of the game.
		public let slug: String

		/// The media object of the poster of the game.
		public let poster: Media?

		/// The media object of the banner of the game.
		public let banner: Media?

		/// The media object of the logo of the game.
		public let logo: Media?

		/// The original title in the original language of the game.
		public let originalTitle: String?

		/// The localized title of the game.
		public let title: String

		/// The synonym titles of the game.
		public let synonymTitles: [String]?

		/// The localized tagline of the game.
		public let tagline: String?

		/// The localized synopsis of the game.
		public let synopsis: String?

		/// The genres of the game.
		public let genres: [String]?

		/// The themes of the game.
		public let themes: [String]?

		/// The studio of the game.
		public let studio: String?

		/// The languages of the game.
		public let languages: [Language]

		/// The tv rating of the game.
		public let tvRating: TVRating

		/// The type of the game.
		public let type: MediaType

		/// The adaptation source of the game.
		public let source: AdaptationSource

		/// The airing status of the game.
		public let status: AiringStatus

		/// The number of editions in the game.
		public let editionCount: Int

		/// The stats of the game.
		public let stats: MediaStat?

		/// The first publication date of the game.
		public let startedAt: Date?

		/// The last publication date of the game.
		public let endedAt: Date?

		/// The duration of the game.
		public let duration: String

		/// The calculated total duration of the game.
		public let durationTotal: String

		/// The season the game has published in.
		public let publicationSeason: String?

		/// The time the game has published at in UTC.
		public let publicationTime: String?

		/// The day the game has published on.
		public let publicationDay: String?

		/// Whether the game is Not Safe For Work.
		public let isNSFW: Bool

		/// The copyright text of the game.
		public let copyright: String?

		/// The library attributes of the game.
		public var library: LibraryAttributes?
	}
}
