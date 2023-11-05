//
//  ShowAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Show {
	/// A root object that stores information about a single show, such as the show's title, episode count, and air date.
	public struct Attributes: LibraryAttributes {
		// MARK: - Properties
		// General
		/// The AniDB id of the show.
		public let anidbID: Int?

		/// The AniList id of the show.
		public let anilistID: Int?

		/// The Anime-Planet id of the show.
		public let animePlanetID: String?

		/// The AniSearch id of the show.
		public let anisearchID: Int?

		/// The IMDB id of the show.
		public let imdbID: String?

		/// The Kitsu id of the show.
		public let kitsuID: Int?

		/// The MyAnimeList id of the show.
		public let malID: Int?

		/// The Notify id of the show.
		public let notifyID: String?

		/// The Syoboi id of the show.
		public let syoboiID: Int?

		/// The Trakt id of the show.
		public let traktID: Int?

		/// The TVDB id of the show.
		public let tvdbID: Int?

		/// The slug of the show.
		public let slug: String

		/// The video url of the show.
		public let videoUrl: String?

		/// The media object of the poster of the show.
		public let poster: Media?

		/// The media object of the banner of the show.
		public let banner: Media?

		/// The media object of the logo of the show.
		public let logo: Media?

		/// The original title in the original language of the show.
		public let originalTitle: String?

		/// The localized title of the show.
		public let title: String

		/// The synonym titles of the show.
		public let synonymTitles: [String]?

		/// The localized tagline of the show.
		public let tagline: String?

		/// The localized synopsis of the show.
		public let synopsis: String?

		/// The genres of the show.
		public let genres: [String]?

		/// The themes of the show.
		public let themes: [String]?

		/// The studio of the show.
		public let studio: String?

		/// The languages of the show.
		public let languages: [Language]

		/// The tv rating of the show.
		public let tvRating: TVRating

		/// The type of the show.
		public let type: MediaType

		/// The adaptation source of the show.
		public let source: AdaptationSource

		/// The airing status of the show.
		public let status: AiringStatus

		/// The number of episodes in the show.
		public let episodeCount: Int

		/// The number of seasons in the show.
		public let seasonCount: Int

		/// The stats of the show.
		public let stats: MediaStat?

		/// The first air date of the show.
		public let startedAt: Date?

		/// The last air date of the show.
		public let endedAt: Date?

		/// The duration of the show.
		public let duration: String

		/// The calculated total duration of the show.
		public let durationTotal: String

		/// The season the show has aired in.
		public let airSeason: String?

		/// The time the show has aired at in UTC.
		public let airTime: String?

		/// The day the show has aired on.
		public let airDay: String?

		/// Whether the show is Not Safe For Work.
		public let isNSFW: Bool

		/// The copyright text of the show.
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
