//
//  Notification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of notifications.
*/
public class UserNotification: JSONDecodable {
	// MARK: - Properties
	/// The collection of notifications.
	public let notifications: [UserNotificationElement]

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var notifications = [UserNotificationElement]()

		let notificationsArray = json["notifications"].arrayValue
		for notificationsItem in notificationsArray {
			if let userNotificationElement = try? UserNotificationElement(json: notificationsItem) {
				notifications.append(userNotificationElement)
			}
		}

		self.notifications = notifications

//		let sortedNotifications = notifications.sorted(by: { $0.creationDate?.toDate ?? Date() > $1.creationDate?.toDate ?? Date() })
//		self.notifications = sortedNotifications
	}
}
