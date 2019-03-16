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
	let averageRating: Int?
	let airDate: String?
	let status: String?
	let posterThumbnail: String?

	// User search keys
	let username: String?
	let reputationCount: Int?
	let avatar: String?

	// Thread search unique keys
	let contentTeaser: String?
	let locked: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue

		// Show search unique values
		self.title = json["title"].stringValue
		self.averageRating = json["average_rating"].intValue
		self.airDate = json["air_date"].stringValue
		self.status = json["status"].stringValue
		self.posterThumbnail = json["poster_thumbnail"].stringValue

		// User search unique values
		self.username = json["username"].stringValue
		self.reputationCount = json["reputation_count"].intValue
		self.avatar = json["avatar"].stringValue

		// Thread search unique values
		self.contentTeaser = json["content_teaser"].stringValue
		self.locked = json["locked"].boolValue
	}
}
