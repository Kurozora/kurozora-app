//
//  Episodes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of episodes, such as the episodes' season.
*/
public class Episodes: JSONDecodable {
	// MARK: - Properties
	/// The season object related to the episodes.
	public let season: EpisodeSeason?

	/// The collection of episodes.
	public let episodes: [EpisodeElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.season = try? EpisodeSeason(json: json["season"])
		var episodes = [EpisodeElement]()

		let episodesArray = json["episodes"].arrayValue
		for episodeItem in episodesArray {
			if let episodeElement = try? EpisodeElement(json: episodeItem) {
				episodes.append(episodeElement)
			}
		}

		self.episodes = episodes
	}
}
