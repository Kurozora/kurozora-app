//
//  Notification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class UserNotification: JSONDecodable {
	let success: Bool?
	let notifications: [UserNotificationsElement]

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		var notifications = [UserNotificationsElement]()

		let notificationsArray = json["notifications"].arrayValue
		for notificationsItem in notificationsArray {
			if let userNotificationsElement = try? UserNotificationsElement(json: notificationsItem) {
				notifications.append(userNotificationsElement)
			}
		}

		let sortedNotifications = notifications.sorted(by: { $0.creationDate?.toDate ?? Date() > $1.creationDate?.toDate ?? Date() })

		self.notifications = sortedNotifications
	}
}

class UserNotificationsElement: JSONDecodable {
	let id: String?
	let type: String?
	var read: Bool?
	let data: UserNotificationData?
	let message: String?
	let creationDate: String?

	required init(json: JSON) throws {
		self.id = json["id"].stringValue
		self.type = json["type"].stringValue
		self.read = json["read"].boolValue
		self.data = try? UserNotificationData(json: json["data"])
		self.message = json["string"].stringValue
		self.creationDate = json["creation_date"].stringValue
	}
}

class UserNotificationData: JSONDecodable {
	// Session
	let ip: String?
	let sessionID: Int?

	// Follower
	let userID: Int?
	let username: String?
	let profileImage: String?

	required init(json: JSON) throws {
		self.ip = json["ip"].stringValue
		self.sessionID = json["user_id"].intValue

		self.userID = json["user_id"].intValue
		self.username = json["username"].stringValue
		self.profileImage = json["avatar_url"].stringValue
	}
}
