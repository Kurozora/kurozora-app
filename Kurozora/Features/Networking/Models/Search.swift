//
//  Search.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Search: JSONDecodable {
	let success: Bool?
	let results: [SearchElement]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		var results = [SearchElement]()

		let resultsArray = json["results"].arrayValue
		for resultsItem in resultsArray {
			if let searchElement = try? SearchElement(json: resultsItem) {
				results.append(searchElement)
			}
		}

		self.results = results
	}
}

class SearchElement: JSONDecodable {
	let id: Int?

	// Show search keys
	let title: String?
	let posterThumbnail: String?
	let status: String?
	let rating: String?
	let episodeCount: Int?
	let airDate: String?
	let score: Double?

	// User search keys
	let username: String?
	let avatar: String?
	let followerCount: Int?

	// Thread search unique keys
	let contentTeaser: String?
	let locked: Bool?

	// User data keys
	let currentUser: UserProfile?

	required init(json: JSON) throws {
		self.id = json["id"].intValue

		// Show search unique values
		self.title = json["title"].stringValue
		self.posterThumbnail = json["poster_thumbnail"].stringValue
		self.status = json["status"].stringValue
		self.rating = json["rating"].stringValue
		self.episodeCount = json["episode_count"].intValue
		self.airDate = json["air_date"].stringValue
		self.score = json["score"].doubleValue

		// User search unique values
		self.username = json["username"].stringValue
		self.avatar = json["avatar"].stringValue
		self.followerCount = json["follower_count"].intValue

		// Thread search unique values
		self.contentTeaser = json["content_teaser"].stringValue
		self.locked = json["locked"].boolValue

		// User data values
		self.currentUser = try? UserProfile(json: json["current_user"])
	}
}
