//
//  Seasons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Seasons: JSONDecodable {
    let success: Bool?
    let seasons: [SeasonsElement]?

    required init(json: JSON) throws {
        self.success = json["success"].boolValue
		var seasons = [SeasonsElement]()

		let seasonsArray = json["seasons"].arrayValue
		for seasonItem in seasonsArray {
			if let seasonsElement = try? SeasonsElement(json: seasonItem) {
				seasons.append(seasonsElement)
			}
		}
        self.seasons = seasons
    }
}

class SeasonsElement: JSONDecodable {
	let id: Int?
	let title: String?
	let number: Int?
	let poster: String?
	let episodesCount: Int?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.number = json["number"].intValue
		self.poster = json["poster"].stringValue
		self.episodesCount = json["episodes_count"].intValue
	}
}
