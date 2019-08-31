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

		let sortedNotifications = notifications.sorted(by: {Date.stringToDateTime(string: $0.creationDate) > Date.stringToDateTime(string: $1.creationDate)})

		self.notifications = sortedNotifications
	}
}

class UserNotificationsElement: JSONDecodable {
	let id: Int?
	let userID: Int?
	let type: String?
	var read: Bool?
	let data: UserNotificationData?
	let message: String?
	let creationDate: String?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.userID = json["user_id"].intValue
		self.type = json["type"].stringValue
		self.read = json["read"].boolValue
		self.data = try? UserNotificationData(json: json["data"])
		self.message = json["string"].stringValue
		self.creationDate = json["creation_date"].stringValue
	}
}

class UserNotificationData: JSONDecodable {
	let ip: String?
	let sessionID: Int?
	let name: String?
	let avatar: String?

	required init(json: JSON) throws {
		self.ip = json["ip"].stringValue
		self.sessionID = json["session_id"].intValue
		self.name = json["follower_name"].stringValue
		self.avatar = json["follower_avatar"].stringValue
	}
}
