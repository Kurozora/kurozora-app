//
//  NotificationOptions.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension KNotification {
	/**
		List of notification options.

		```
		case allowNotifications = 0
		case sounds = 1
		case badge = 2
		```
	*/
	enum Options: Int {
		/// Indicates if the in-app notifications are allowed.
		case allowNotifications = 0

		/// Indicates if a sound should be played when a notification is shown.
		case sounds

		/// Indicates if the notifications tab icon should show a badge with the number of unread notifications.
		case badge
	}
}
