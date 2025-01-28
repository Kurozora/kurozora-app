//
//  GameAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

extension Game {
	/// A root object that stores information about a single game, such as the game's title, episode count, and air date.
	public struct Attributes: Codable, Sendable {
		// MARK: - Properties
		/// The game's IGDB ID.
		public let igdbID: Int?

		/// The game's IGDB slug.
		public let igdbSlug: String?

		/// The game's slug.
		public let slug: String

		/// The game's poster's media object.
		public let poster: Media?

		/// The game's banner's media object.
		public let banner: Media?

		/// The game's logo's media object.
		public let logo: Media?

		/// The game's original title in the original language.
		public let originalTitle: String?

		/// The game's localized title.
		public let title: String

		/// The game's synonym titles.
		public let synonymTitles: [String]?

		/// The game's localized tagline.
		public let tagline: String?

		/// The game's localized synopsis.
		public let synopsis: String?

		/// The game's genres.
		public let genres: [String]?

		/// The game's themes.
		public let themes: [String]?

		/// The game's studio.
		public let studio: String?

		/// The game's languages.
		public let languages: [Language]

		/// The game's country of origin.
		public let countryOfOrigin: Country?

		/// The game's tv rating.
		public let tvRating: TVRating

		/// The game's type.
		public let type: MediaType

		/// The game's adaptation source.
		public let source: AdaptationSource

		/// The game's airing status.
		public let status: AiringStatus

		/// The number of editions in the game.
		public let editionCount: Int

		/// The game's stats.
		public let stats: MediaStat?

		/// The game's first publication date.
		public let startedAt: Date?

		/// The game's last publication date.
		public let endedAt: Date?

		/// The game's duration.
		public let duration: String

		/// The game's duration in seconds.
		public let durationCount: Int

		/// The game's calculated total duration.
		public let durationTotal: String

		/// The game's calculated total duration in seconds.
		public let durationTotalCount: Int

		/// The season the game has published in.
		public let publicationSeason: String?

		/// The time the game has published at in UTC.
		public let publicationTime: String?

		/// The day the game has published on.
		public let publicationDay: String?

		/// Whether the game is Not Safe For Work.
		public let isNSFW: Bool

		/// The game's copyright text.
		public let copyright: String?

		/// The game's library attributes.
		public var library: LibraryAttributes?
	}
}
