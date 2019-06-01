//
//  NotificationOptions.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification options

	- case allowNotifications = 0
	- case sounds = 1
	- case vibrations = 2
	- case badge = 3
*/
enum NotificationOptions: Int {
	case allowNotifications = 0
	case sounds
	case vibrations
	case badge
}
