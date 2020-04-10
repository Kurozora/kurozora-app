//
//  Seasons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class Seasons: JSONDecodable {
	// MARK: - Properties
    internal let success: Bool?
    public let seasons: [SeasonsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
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

public class SeasonsElement: JSONDecodable {
	// MARK: - Properties
	public let id: Int?
	public let title: String?
	public let number: Int?
	public let poster: String?
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
