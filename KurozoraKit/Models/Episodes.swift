//
//  Episodes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Episodes: JSONDecodable {
	let success: Bool?
	let season: EpisodesSeason?
	let episodes: [EpisodesElement]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.season = try? EpisodesSeason(json: json["season"])
		var episodes = [EpisodesElement]()

		let episodesArray = json["episodes"].arrayValue
		for episodeItem in episodesArray {
			if let episodesElement = try? EpisodesElement(json: episodeItem) {
				episodes.append(episodesElement)
			}
		}

		self.episodes = episodes
	}
}

class EpisodesElement: JSONDecodable {
	let id: Int?
	let number: Int?
	let name: String?
	let screenshot: String?
	let firstAired: String?
	let overview: String?
	let verified: Bool?
	let userDetails: EpisodesUserDetails?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.number = json["number"].intValue
		self.name = json["name"].stringValue
		self.screenshot = json["screenshot"].stringValue
		self.firstAired = json["first_aired"].string
		self.overview = json["overview"].string
		self.verified = json["verified"].boolValue
		self.userDetails = try? EpisodesUserDetails(json: json["user_details"])
	}
}

class EpisodesUserDetails: JSONDecodable {
	let success: Bool?
	var watched: Bool?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.watched = json["watched"].boolValue
	}
}

class EpisodesSeason: JSONDecodable {
	let id: Int?
	let showID: Int?
	let title: String?
	let episodeCount: Int?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.showID = json["anime_id"].intValue
		self.title = json["title"].stringValue
		self.episodeCount = json["episode_count"].intValue
	}
}
