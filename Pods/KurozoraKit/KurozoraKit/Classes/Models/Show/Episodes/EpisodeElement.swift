//
//  EpisodeElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single episode, such as the episodes's number, name, and air date.
*/
public class EpisodeElement: JSONDecodable {
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
	public let userDetails: EpisodeUserDetails?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.number = json["number"].intValue
		self.name = json["name"].stringValue
		self.screenshot = json["screenshot"].stringValue
		self.firstAired = json["first_aired"].string
		self.overview = json["overview"].string
		self.verified = json["verified"].boolValue
		self.userDetails = try? EpisodeUserDetails(json: json["user_details"])
	}
}
