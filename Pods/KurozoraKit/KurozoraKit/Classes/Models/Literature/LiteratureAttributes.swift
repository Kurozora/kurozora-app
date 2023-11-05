//
//  LiteratureAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

extension Literature {
	/// A root object that stores information about a single literature, such as the literature's title, episode count, and air date.
	public struct Attributes: LibraryAttributes {
		// MARK: - Properties
		// General
		/// The AniDB id of the literature.
		public let anidbID: Int?

		/// The AniList id of the literature.
		public let anilistID: Int?

		/// The Anime-Planet id of the literature.
		public let animePlanetID: String?

		/// The AnimeSearch id of the literature.
		public let anisearchID: Int?

		/// The Kitsu id of the literature.
		public let kitsuID: Int?

		/// The MyAnimeList id of the literature.
		public let malID: Int?

		/// The slug of the literature.
		public let slug: String

		/// The media object of the poster of the literature.
		public let poster: Media?

		/// The media object of the banner of the literature.
		public let banner: Media?

		/// The media object of the logo of the literature.
		public let logo: Media?

		/// The original title in the original language of the literature.
		public let originalTitle: String?

		/// The localized title of the literature.
		public let title: String

		/// The synonym titles of the literature.
		public let synonymTitles: [String]?

		/// The localized tagline of the literature.
		public let tagline: String?

		/// The localized synopsis of the literature.
		public let synopsis: String?

		/// The genres of the literature.
		public let genres: [String]?

		/// The themes of the literature.
		public let themes: [String]?

		/// The studio of the literature.
		public let studio: String?

		/// The languages of the literature.
		public let languages: [Language]

		/// The tv rating of the literature.
		public let tvRating: TVRating

		/// The type of the literature.
		public let type: MediaType

		/// The adaptation source of the literature.
		public let source: AdaptationSource

		/// The airing status of the literature.
		public let status: AiringStatus

		/// The number of volumes in the literature.
		public let volumeCount: Int

		/// The number of chapters in the literature.
		public let chapterCount: Int

		/// The number of pages in the literature.
		public let pageCount: Int

		/// The stats of the literature.
		public let stats: MediaStat?

		/// The first publication date of the literature.
		public let startedAt: Date?

		/// The last publication date of the literature.
		public let endedAt: Date?

		/// The duration of the literature.
		public let duration: String

		/// The calculated total duration of the literature.
		public let durationTotal: String

		/// The season the literature has published in.
		public let publicationSeason: String?

		/// The time the literature has published at in UTC.
		public let publicationTime: String?

		/// The day the literature has published on.
		public let publicationDay: String?

		/// Whether the literature is Not Safe For Work.
		public let isNSFW: Bool

		/// The copyright text of the literature.
		public let copyright: String?

		// Library attirbutes
		public var givenRating: Double?

		public var givenReview: String?

		public var libraryStatus: KKLibrary.Status?

		public var isFavorited: Bool?

		public var _favoriteStatus: FavoriteStatus?

		public var isReminded: Bool?

		public var _reminderStatus: ReminderStatus?
	}
}
