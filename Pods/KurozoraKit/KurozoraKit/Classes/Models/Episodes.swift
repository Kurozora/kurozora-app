//
//  Episodes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of episodes, such as the episodes' season.
*/
public class Episodes: JSONDecodable {
	// MARK: - Properties
	/// The season object related to the episodes.
	public let season: EpisodesSeason?

	/// The collection of episodes.
	public let episodes: [EpisodesElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single episode, such as the episodes's number, name, and air date.
*/
public class EpisodesElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the episodes.
	public let id: Int?

	/// The number of the episode.
	public let number: Int?

	/// The name of the episodes.
	public let name: String?

	/// The link to a screenshot of the episode.
	public let screenshot: String?

	/// The air date of the episode.
	public let firstAired: String?

	/// The overview text of the episode.
	public let overview: String?

	/// Whether the episode details have been verified.
	public let verified: Bool?

	/// The user details asocciated with the episode.
	public let userDetails: EpisodesUserDetails?

	// MARK: - Initializers
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

/**
	A mutable object that stores information about a single user's details, such as the watch status of the episode.
*/
public class EpisodesUserDetails: JSONDecodable {
	// MARK: - Properties
	/// The watch status of the episode.
	public var watchStatus: WatchStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.watchStatus = WatchStatus(rawValue: json["watched"].intValue)
	}
}

/**
	A mutable object that stores information about an episode's season, such as the season's title, and episode count.
*/
public class EpisodesSeason: JSONDecodable {
	// MARK: - Properties
	/// The id of the season.
	public let id: Int?

	/// The show id to which the season belongs.
	public let showID: Int?

	/// The title of the season.
	public let title: String?

	/// The episodes count of the season.
	public let episodeCount: Int?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.showID = json["anime_id"].intValue
		self.title = json["title"].stringValue
		self.episodeCount = json["episode_count"].intValue
	}
}
