//
//  Episodes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class Episodes: JSONDecodable {
	public let success: Bool?
	public let season: EpisodesSeason?
	public let episodes: [EpisodesElement]?

	required public init(json: JSON) throws {
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

public class EpisodesElement: JSONDecodable {
	public let id: Int?
	public let number: Int?
	public let name: String?
	public let screenshot: String?
	public let firstAired: String?
	public let overview: String?
	public let verified: Bool?
	public let userDetails: EpisodesUserDetails?

	required public init(json: JSON) throws {
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

public class EpisodesUserDetails: JSONDecodable {
	public let success: Bool?
	public var watched: Bool?

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.watched = json["watched"].boolValue
	}
}

public class EpisodesSeason: JSONDecodable {
	public let id: Int?
	public let showID: Int?
	public let title: String?
	public let episodeCount: Int?

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.showID = json["anime_id"].intValue
		self.title = json["title"].stringValue
		self.episodeCount = json["episode_count"].intValue
	}
}
