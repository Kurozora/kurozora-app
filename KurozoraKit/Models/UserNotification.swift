//
//  Notification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class UserNotification: JSONDecodable {
	// MARK: - Properties
	internal let success: Bool?
	public let notifications: [UserNotificationsElement]

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
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

public class UserNotificationsElement: JSONDecodable {
	// MARK: - Properties
	public let id: String?
	public let type: String?
	public var read: Bool?
	public let data: UserNotificationData?
	public let message: String?
	public let creationDate: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].stringValue
		self.type = json["type"].stringValue
		self.read = json["read"].boolValue
		self.data = try? UserNotificationData(json: json["data"])
		self.message = json["string"].stringValue
		self.creationDate = json["creation_date"].stringValue
	}
}

public class UserNotificationData: JSONDecodable {
	// MARK: - Properties
	// Session
	public let ip: String?
	public let sessionID: Int?

	// Follower
	public let userID: Int?
	public let username: String?
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
