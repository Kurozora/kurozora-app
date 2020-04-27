//
//  GroupedNotifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import Foundation

/**
	List of notification grouping

	```
	var sectionTitle: String!
	var sectionNotifications: [UserNotificationsElement]!
	```
*/
struct GroupedNotifications {
	var sectionTitle: String!
	var sectionNotifications: [UserNotificationElement]!
}
