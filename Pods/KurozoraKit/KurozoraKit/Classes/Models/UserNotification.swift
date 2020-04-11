//
//  Notification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of notifications.
*/
public class UserNotification: JSONDecodable {
	// MARK: - Properties
	/// The collection of notifications.
	public let notifications: [UserNotificationsElement]

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var notifications = [UserNotificationsElement]()

		let notificationsArray = json["notifications"].arrayValue
		for notificationsItem in notificationsArray {
			if let userNotificationsElement = try? UserNotificationsElement(json: notificationsItem) {
				notifications.append(userNotificationsElement)
			}
		}

		self.notifications = notifications

//		let sortedNotifications = notifications.sorted(by: { $0.creationDate?.toDate ?? Date() > $1.creationDate?.toDate ?? Date() })
//		self.notifications = sortedNotifications
	}
}

/**
	A mutable object that stores information about a single notification, such as the notification's type, read status, and containing data.
*/
public class UserNotificationsElement: JSONDecodable {
	// MARK: - Properties
	/// The id of a notification.
	public let id: String?

	/// The type of a notification.
	public let type: String?

	/// The read status of a notification.
	public var readStatus: ReadStatus?

	/// The data of the notification.
	public let data: UserNotificationData?

	/// The message of the notification.
	public let message: String?

	/// The creation date of the notification.
	public let creationDate: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].stringValue
		self.type = json["type"].stringValue
		self.readStatus = ReadStatus(from: json["read"].boolValue)
		self.data = try? UserNotificationData(json: json["data"])
		self.message = json["string"].stringValue
		self.creationDate = json["creation_date"].stringValue
	}
}

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
