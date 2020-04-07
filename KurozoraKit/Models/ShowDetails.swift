//
//  ShowDetails.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class ShowDetails: JSONDecodable {
	// MARK: - Properties
	public let success: Bool?
	public var showDetailsElement: ShowDetailsElement?
	public let showDetailsElements: [ShowDetailsElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.showDetailsElement = try? ShowDetailsElement(json: json["anime"])

		var showDetailsElements = [ShowDetailsElement]()
		let showDetailsElementsArray = json["anime"].arrayValue
		for showDetailsElementItem in showDetailsElementsArray {
			if let showDetailsElement = try? ShowDetailsElement(json: showDetailsElementItem) {
				showDetailsElements.append(showDetailsElement)
			}
		}
		self.showDetailsElements = showDetailsElements
	}
}

public class ShowDetailsElement: JSONDecodable {
	// MARK: - Properties
	// General
	public let id: Int?
	public let imdbID: String?
	public let banner: String?
	public let bannerThumbnail: String?
	public let genres: [GenreElement]?
	public let poster: String?
	public let posterThumbnail: String?
	public let title: String?

	// Details
	public let airDate: String?
	public let episodes: Int?
	public let runtime: Int?
	public let screenshots: [String]?
	public let seasons: Int?
	public let airStatus: String?
	public let synopsis: String?
	public let tagline: String?
	public let type: String?
	public let watchRating: String?
	public let year: Int?

	// Ratings & ranks
	public let averageRating: Double?
	public let endDate: String?
	public let network: String?
	public let nsfw: Bool?
	public let popularityRank: Int?
	public let producers: String?
	public let rank: Int?
	public let age: String?
	public let ratingCount: Int?

	// Schedule
	public let startDate: String?
	public let airTime: String?
	public var airDay = DateComponents().weekday

	// Extra's
	public let englishTitles: String?
	public let externalLinks: String?
	public let japaneseTitles: String?
	public let languages: String?
	public let synonyms: String?
	public let videoUrl: String?

	// User details
	public var currentUser: UserProfile?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		// Anime
		self.id = json["id"].intValue
		self.imdbID = json["imdb_id"].stringValue
		self.banner = json["background"].stringValue
		self.bannerThumbnail = json["background_thumbnail"].stringValue
		var genres = [GenreElement]()
		let genresArray = json["genres"].arrayValue
		for genreItem in genresArray {
			if let genreElement = try? GenreElement(json: genreItem) {
				genres.append(genreElement)
			}
		}
		self.genres = genres
		self.poster = json["poster"].stringValue
		self.posterThumbnail = json["poster_thumbnail"].stringValue
		self.title = json["title"].stringValue

		// Details
		self.airDate = json["air_date"].stringValue
		self.episodes = json["episodes"].intValue
		self.runtime = json["runtime"].intValue
		self.screenshots = json["screenshots"].rawValue as? [String]
		self.seasons = json["seasons"].intValue
		self.airStatus = json["status"].stringValue
		self.synopsis = json["synopsis"].stringValue
		self.tagline = json["tagline"].stringValue
		self.type = json["type"].stringValue
		self.watchRating = json["watch_rating"].stringValue
		self.year = json["year"].intValue

		// Ratings & ranks
		self.averageRating = json["average_rating"].doubleValue
		self.endDate = json["end_date"].stringValue
		self.network = json["network"].stringValue
		self.nsfw = json["nsfw"].boolValue
		self.popularityRank = json["popularity_rank"].intValue
		self.producers = json["producers"].stringValue
		self.rank = json["rank"].intValue
		self.age = json["age"].stringValue
		self.ratingCount = json["rating_count"].intValue

		// Schedule
		self.startDate = json["first_aired"].stringValue
		self.airTime = json["air_time"].stringValue
		self.airDay = json["air_time"].intValue

		// Extra's
		self.englishTitles = json["english_titles"].stringValue
		self.externalLinks = json["external_links"].stringValue
		self.japaneseTitles = json["japanese_titles"].stringValue
		self.languages = json["languages"].stringValue
		self.synonyms = json["synonyms"].stringValue
		self.videoUrl = json["video_url"].stringValue

		// User details
		self.currentUser = try? UserProfile(json: json["current_user"])
	}
}

// MARK: - Helpers
extension ShowDetailsElement {
	/**
		Returns a string containing all the necessary information of a show. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · TV-MA · 25eps · 25min · 2016"
		```
	*/
	public var informationString: String {
		var informationString = ""

		if let type = self.type, !type.isEmpty {
			informationString += "\(type)"
		}

		if let watchRating = self.watchRating, !watchRating.isEmpty {
			informationString += " · \(watchRating)"
		}

		if let episodes = self.episodes {
			informationString += " · \(episodes)ep\(episodes > 1 ? "s" : "")"
		}

		if let runtime = self.runtime {
			informationString += " · \(runtime)min"
		}

		if let year = self.year {
			informationString += " · \(year)"
		}

		return informationString
	}

	/**
		Returns a short version of the shows information. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · ✓ 10/25 · ☆ 5"
		```
	*/
	public var informationStringShort: String {
		var informationString = ""

		if let type = self.type, !type.isEmpty {
			informationString += "\(type)"
		}

		if let totalEpisodes = self.episodes, let watchedEpisodes = self.currentUser?.watchedEpisodes {
			informationString += " · ✓ \(watchedEpisodes)/\(totalEpisodes)"
		}

		if let currentRating = self.currentUser?.currentRating {
			informationString += " · ☆ \(currentRating)"
		}

		return informationString
	}

	/**
		Returns the full air date of the show.

		```
		"2016-04-16 18:30:00"
		```
	*/
	public var fullAirDate: String? {
		guard let airDate = self.airDate?.toDate else { return nil }
		guard let airTime = self.airTime?.toDate else { return nil }

		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .none
		let airDateString = dateFormatter.string(from: airDate)

		print("------ \(airDateString)")
		return "\(airDateString) \(airTime)"
	}

	/// Create an NSUserActivity from the selected show.
	public var openDetailUserActivity: NSUserActivity? {
		guard let id = id else { return nil }
		let userActivity = NSUserActivity(activityType: "OpenAnimeIntent")
		userActivity.title = "OpenShowDetail"
		userActivity.userInfo = ["showID": id]
		return userActivity
	}
}
