//
//  EpisodeSeason.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about an episode's season, such as the season's title, and episode count.
*/
public class EpisodeSeason: JSONDecodable {
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
