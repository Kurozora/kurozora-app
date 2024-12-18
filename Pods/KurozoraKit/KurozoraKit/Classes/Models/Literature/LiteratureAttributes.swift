//
//  LiteratureAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

extension Literature {
	/// A root object that stores information about a single literature, such as the literature's title, episode count, and air date.
	public struct Attributes: Codable {
		// MARK: - Properties
		// General
		/// The literature's AniDB ID.
		public let anidbID: Int?

		/// The literature's AniList ID.
		public let anilistID: Int?

		/// The literature's Anime-Planet ID.
		public let animePlanetID: String?

		/// The literature's AnimeSearch ID.
		public let anisearchID: Int?

		/// The literature's Kitsu ID.
		public let kitsuID: Int?

		/// The literature's MyAnimeList ID.
		public let malID: Int?

		/// The literature's slug.
		public let slug: String

		/// The literature's poster's media object.
		public let poster: Media?

		/// The literature's banner's media object.
		public let banner: Media?

		/// The literature's logo's media object.
		public let logo: Media?

		/// The literature's original title in the original language.
		public let originalTitle: String?

		/// The literature's localized title.
		public let title: String

		/// The literature's synonym titles.
		public let synonymTitles: [String]?

		/// The literature's localized tagline.
		public let tagline: String?

		/// The literature's localized synopsis.
		public let synopsis: String?

		/// The literature's genres.
		public let genres: [String]?

		/// The literature's themes.
		public let themes: [String]?

		/// The literature's studio.
		public let studio: String?

		/// The literature's languages.
		public let languages: [Language]

		/// The literature's country of origin.
		public let countryOfOrigin: Country?

		/// The literature's tv rating.
		public let tvRating: TVRating

		/// The literature's type.
		public let type: MediaType

		/// The literature's adaptation source.
		public let source: AdaptationSource

		/// The literature's airing status.
		public let status: AiringStatus

		/// The literature's number of volumes.
		public let volumeCount: Int

		/// The literature's number of chapters.
		public let chapterCount: Int

		/// The literature's number of pages.
		public let pageCount: Int

		/// The literature's stats.
		public let stats: MediaStat?

		/// The literature's first publication date.
		public let startedAt: Date?

		/// The literature's last publication date.
		public let endedAt: Date?

		/// The literature's next publication date.
		public let nextPublicationAt: Date?

		/// The literature's duration.
		public let duration: String

		/// The literature's duration in seconds.
		public let durationCount: Int

		/// The literature's calculated total duration.
		public let durationTotal: String

		/// The literature's calculated total duration in seconds.
		public let durationTotalCount: Int

		/// The season the literature has published in.
		public let publicationSeason: String?

		/// The time the literature has published at in UTC.
		public let publicationTime: String?

		/// The day the literature has published on.
		public let publicationDay: String?

		/// Whether the literature is Not Safe For Work.
		public let isNSFW: Bool

		/// The literature's copyright text.
		public let copyright: String?

		/// The literature's library attributes.
		public var library: LibraryAttributes?
	}
}
