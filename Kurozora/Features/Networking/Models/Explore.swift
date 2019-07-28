//
//  Explore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Explore: JSONDecodable {
    let success: Bool?
	let categories: [ExploreCategory]?
    let banners: [ExploreElement]?

    required init(json: JSON) throws {
        success = json["success"].boolValue
		var categories = [ExploreCategory]()
		var banners = [ExploreElement]()

		let categoriesArray = json["categories"].arrayValue
		for categoriesItem in categoriesArray {
			if let exploreCategories = try? ExploreCategory(json: categoriesItem) {
				categories.append(exploreCategories)
			}
		}

		let bannersArray = json["banners"].arrayValue
		for bannersItem in bannersArray {
			if let exploreBanner = try? ExploreElement(json: bannersItem) {
				banners.append(exploreBanner)
			}
		}

		self.categories = categories
		self.banners = banners
    }
}

class ExploreElement: JSONDecodable {
	let id: Int?
	let title: String?
	let tagline: String?
	let averageRating: Double?
	let poster: String?
	let posterThumbnail: String?
	let banner: String?
	let bannerThumbnail: String?
	let videoUrl: String?
	let genres: [GenreElement]?
	var userProfile: UserProfile?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.tagline = json["tagline"].stringValue
		self.averageRating = json["average_rating"].doubleValue
		self.poster = json["poster"].stringValue
		self.posterThumbnail = json["poster_thumbnail"].stringValue
		self.banner = json["background"].stringValue
		self.bannerThumbnail = json["background_thumbnail"].stringValue
		self.videoUrl = json["video_url"].stringValue
		var genres = [GenreElement]()
		let userProfileJson = json["user"]

		let genresArray = json["genres"].arrayValue
		for genreItem in genresArray {
			if let genresElement = try? GenreElement(json: genreItem) {
				genres.append(genresElement)
			}
		}
		let userProfile = try? UserProfile(json: userProfileJson)

		self.genres = genres
		self.userProfile = userProfile
	}
}

class ExploreCategory: JSONDecodable {
	let title: String?
	let size: String?
	let shows: [ExploreElement]?
	let genres: [GenreElement]?

	required init(json: JSON) throws {
		self.title = json["title"].stringValue
		self.size = json["size"].stringValue
		var shows = [ExploreElement]()
		var genres = [GenreElement]()

		let showsArray = json["shows"].arrayValue
		for showItem in showsArray {
			if let banner = try? ExploreElement(json: showItem) {
				shows.append(banner)
			}
		}

		self.shows = shows

		let genresArray = json["genres"].arrayValue
		for genreItem in genresArray {
			if let genre = try? GenreElement(json: genreItem) {
				genres.append(genre)
			}
		}

		self.genres = genres
	}
}
