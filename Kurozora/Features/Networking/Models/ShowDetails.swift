//
//  ShowDetails.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ShowDetails: JSONDecodable {
	let success: Bool?
	var showDetailsElement: ShowDetailsElement?
	let showDetailsElements: [ShowDetailsElement]?

	required init(json: JSON) throws {
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

class ShowDetailsElement: JSONDecodable {
	// General
	let id: Int?
	let imdbID: String?
	let banner: String?
	let bannerThumbnail: String?
	let genres: [GenreElement]?
	let poster: String?
	let posterThumbnail: String?
	let title: String?

	// Details
	let airDate: String?
	let episodes: Int?
	let runtime: Int?
	let screenshots: [String]?
	let seasons: Int?
	let status: String?
	let synopsis: String?
	let tagline: String?
	let type: String?
	let watchRating: String?
	let year: Int?

	// Ratings & ranks
	let averageRating: Double?
	let endDate: String?
	let network: String?
	let nsfw: Bool?
	let popularityRank: Int?
	let producers: String?
	let rank: Int?
	let age: String?
	let ratingCount: Int?
	let startDate: String?

	// Extra's
	let englishTitles: String?
	let externalLinks: String?
	let japaneseTitles: String?
	let languages: String?
	let synonyms: String?
	let videoUrl: String?

	// User details
	var currentUser: UserProfile?

	required init(json: JSON) throws {
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
		self.status = json["status"].stringValue
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
		self.startDate = json["start_date"].stringValue

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

	/**
		Returns a string containing all the necessary information of a show. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · TV-MA · 25eps · 25min · 2016"
		```
	*/
	var informationString: String {
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
	var informationStringShort: String {
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

	/// Create an NSUserActivity from the selected show.
	var openDetailUserActivity: NSUserActivity? {
		guard let id = id else { return nil }
		let userActivity = NSUserActivity(activityType: "OpenAnimeIntent")
		userActivity.title = "OpenShowDetail"
		userActivity.userInfo = ["showID": id]
		return userActivity
	}
}
