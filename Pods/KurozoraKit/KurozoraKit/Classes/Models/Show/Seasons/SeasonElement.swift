//
//  SeasonElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single season, such as the season's title, number, and episodes count.
*/
public class SeasonElement: JSONDecodable {
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
