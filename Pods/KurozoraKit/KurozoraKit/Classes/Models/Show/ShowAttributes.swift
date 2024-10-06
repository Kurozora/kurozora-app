//
//  ShowAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Show {
	/// A root object that stores information about a single show, such as the show's title, episode count, and air date.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The show's AniDB ID.
		public let anidbID: Int?

		/// The show's AniList ID.
		public let anilistID: Int?

		/// The show's Anime-Planet ID.
		public let animePlanetID: String?

		/// The show's AniSearch ID.
		public let anisearchID: Int?

		/// The show's IMDB ID.
		public let imdbID: String?

		/// The show's Kitsu ID.
		public let kitsuID: Int?

		/// The show's MyAnimeList ID.
		public let malID: Int?

		/// The show's Notify ID.
		public let notifyID: String?

		/// The show's Syoboi ID.
		public let syoboiID: Int?

		/// The show's Trakt ID.
		public let traktID: Int?

		/// The show's TVDB ID.
		public let tvdbID: Int?

		/// The show's slug.
		public let slug: String

		/// The show's video url.
		public let videoUrl: String?

		/// The show's poster's media object.
		public let poster: Media?

		/// The show's banner's media object.
		public let banner: Media?

		/// The show's logo's media object.
		public let logo: Media?

		/// The show's original title in the original language.
		public let originalTitle: String?

		/// The show's localized title.
		public let title: String

		/// The show's synonym titles.
		public let synonymTitles: [String]?

		/// The show's localized tagline.
		public let tagline: String?

		/// The show's localized synopsis.
		public let synopsis: String?

		/// The show's genres.
		public let genres: [String]?

		/// The show's themes.
		public let themes: [String]?

		/// The show's studio.
		public let studio: String?

		/// The show's languages.
		public let languages: [Language]

		/// The show's country of origin.
		public let countryOfOrigin: Country?

		/// The show's tv rating.
		public let tvRating: TVRating

		/// The show's type.
		public let type: MediaType

		/// The show's adaptation source.
		public let source: AdaptationSource

		/// The show's airing status.
		public let status: AiringStatus

		/// The number of episodes in the show.
		public let episodeCount: Int

		/// The number of seasons in the show.
		public let seasonCount: Int

		/// The show's stats.
		public let stats: MediaStat?

		/// The show's first air date.
		public let startedAt: Date?

		/// The show's last air date.
		public let endedAt: Date?

		/// The show's duration.
		public let duration: String

		/// The show's calculated total duration.
		public let durationTotal: String

		/// The season the show has aired in.
		public let airSeason: String?

		/// The time the show has aired at in UTC.
		public let airTime: String?

		/// The day the show has aired on.
		public let airDay: String?

		/// Whether the show is Not Safe For Work.
		public let isNSFW: Bool

		/// The show's copyright text.
		public let copyright: String?

		/// The show's library attributes.
		public var library: LibraryAttributes?
	}
}
