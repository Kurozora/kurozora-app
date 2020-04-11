//
//  Seasons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of seasons.
*/
public class Seasons: JSONDecodable {
	// MARK: - Properties
	/// The collection of seasons.
    public let seasons: [SeasonsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single season, such as the season's title, number, and episodes count.
*/
public class SeasonsElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the season.
	public let id: Int?

	/// The title of the season.
	public let title: String?

	/// The number of the season.
	public let number: Int?

	/// The link to a poster of the season.
	public let poster: String?

	/// The episodes count of the season.
	public let episodesCount: Int?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.number = json["number"].intValue
		self.poster = json["poster"].stringValue
		self.episodesCount = json["episodes_count"].intValue
	}
}
