//
//  ShowAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Show {
	/**
		A root object that stores information about a single show, such as the show's title, episode count, and air date.
	*/
	public struct Attributes: LibraryAttributes {
		// MARK: - Properties
		// General
		/// The AniList if of the show.
		public let anilistID: Int?

		/// The AniDB if of the show.
		public let anidbID: Int?

		/// The Kitsu if of the show.
		public let kitsuID: Int?

		/// The IMDB id of the show.
		public let imdbID: String?

		/// The MAL id of the show.
		public let malID: Int?

		/// The TVDB id of the show.
		public let tvdbID: Int?

		/// The title of the show.
		public let title: String

		/// The tagline of the show.
		public let tagline: String?

		/// The synopsis of the show.
		public let synopsis: String?

		/// The type of the show.
		public let type: String

		/// The adaptation source of the show.
		public let adaptationSource: String

		/// The network the show has aired on.
		public let network: String?

		/// The name of the producer of the show.
		public let producer: String?

		/// The number of episodes in the show.
		public let episodeCount: Int

		/// The number of seasons in the show.
		public let seasonCount: Int

		/// The average rating of the show.
		public let averageRating: Double

		/// The number of ratings the show accumulated.
		public let ratingCount: Int

//		"userRating": {
//		"ratingCountList": [
//		80, 1 star
//		68,
//		187, 3 stars
//		530,
//		4110 5 stars
//		],
//		"value": 4.7,
//		"ratingCount": 4975,
//		"ariaLabelForRatings": "4.7 stars"
//		},

		/// The watch rating of the show.
		public let watchRating: String

		/// The video url of the show.
		public let videoUrl: String?

		/// The media object of the banner of the show.
		public let banner: Show.Attributes.Media?

		/// The media object of the poster of the show.
		public let poster: Show.Attributes.Media?

		/// The first air date of the show.
		public let firstAired: String?

		/// The last air date of the show.
		public let lastAired: String?

		/// The run time of the show.
		public let runtime: Int

		/// The air status of the show.
		public let airStatus: String

		/// The time the show has aired at.
		public let airTime: String?

		/// The day the show has aired on.
		public let airDay: String?

		/// Whether the show is Not Safe For Work.
		public let isNSFW: Bool

		/// The copyright text of the show.
		public let copyright: String?

		// Extra's
		/// The original title in the original language of the show.
		public let originalTitle: String?

		// Library attirbutes
		public var givenRating: Double?

		public var libraryStatus: KKLibrary.Status?

		public var isFavorited: Bool?

		public var _favoriteStatus: FavoriteStatus?

		public var isReminded: Bool?

		public var _reminderStatus: ReminderStatus?
	}
}

// MARK: - Helpers
extension Show.Attributes {
	/**
		Returns a string containing all the necessary information of a show. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · TV-MA · 25eps · 25min · 2016"
		```
	*/
	public var informationString: String {
		var informationString = ""
		informationString += self.type
		informationString += " · \(self.watchRating)"
		informationString += " · \(self.episodeCount)ep\(self.episodeCount > 1 ? "s" : "")"
		informationString += " · \(self.runtime)min"
		if let airYear = self.airYear {
			informationString += " · \(airYear)"
		}
		return informationString
	}

	/**
		The year the show aired in the first time.

		```
		2016
		```
	*/
	public var airYear: Int? {
		guard let firstAired = self.firstAired else { return nil }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"

		guard let firstAiredDate = dateFormatter.date(from: firstAired) else { return nil }
		let calendar = Calendar.current
		return calendar.component(.year, from: firstAiredDate)
	}

	/**
		Returns a short version of the shows information. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · ✓ 10/25 · ☆ 5"
		```
	*/
	public var informationStringShort: String {
		var informationString = ""
		informationString += "\(self.type)"

//		if let watchedEpisodesCount = self.watchedEpisodesCount {
//			informationString += " · ✓ \(watchedEpisodesCount)/\(self.episodeCount)"
//		}

		if let givenRating = self.givenRating {
			informationString += " · ☆ \(givenRating)"
		}

		return informationString
	}

	/**
		Returns the first air date and time of the show as a string. Returns `nil` if either the date or time is missing.

		```
		"2016-04-16 18:30:00"
		```
	*/
	public var startDateTime: String? {
		guard let airDate = self.firstAired, !airDate.isEmpty else { return nil }
		guard let airTime = self.airTime, !airTime.isEmpty else { return nil }

		let airDateTimeString = airDate + " " + airTime
		return airDateTimeString
	}

	/**
		Returns the end date and time of the show as a string. Returns `nil` if either the date or time is missing.

		```
		"2016-04-16 18:30:00"
		```
	*/
	public var endDateTime: String? {
		return (lastAired ?? "?") + " " + (airTime ?? "?")
	}

	/**
		Returns the next air date and time of the show as a string. Returns `nil` if either the date or time is missing.

		```
		"2016-04-16 18:30:00"
		```
	*/
	public var nextAirDateString: String? {
		return startDateTime
	}

	/**
		Returns the next air date and time of the show.

		```
		"2016-04-16 18:30:00"
		```
	*/
	public var nextAirDate: Date? {
		return startDateTime?.toDate
	}
}
