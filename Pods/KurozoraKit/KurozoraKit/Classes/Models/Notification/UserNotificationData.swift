//
//  UserNotificationData.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single notification type data.
*/
public class UserNotificationData: JSONDecodable {
	// MARK: - Properties
	// Session
	/// [Session] The ip address of a session.
	public let ip: String?

	/// [Session] The id of a session.
	public let sessionID: Int?

	// Follower
	/// [Follower] The if of a follower.
	public let userID: Int?

	/// [Follower] The username of a follower.
	public let username: String?

	/// [Follower] The profile image of the follower.
	public let profileImage: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.ip = json["ip"].stringValue
		self.sessionID = json["user_id"].intValue

		self.userID = json["user_id"].intValue
		self.username = json["username"].stringValue
		self.profileImage = json["avatar_url"].stringValue
	}
}
