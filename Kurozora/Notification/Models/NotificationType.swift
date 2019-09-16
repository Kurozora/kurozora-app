//
//  NotificationType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification types.

	```
	case unknown = "TYPE_UNKNOWN"
	case session = "TYPE_NEW_SESSION"
	case follower = "TYPE_NEW_FOLLOWER"
	```
*/
enum NotificationType: String {
	/// Indicates that the notification has no specific type and thus has the default style.
	case unknown = "TYPE_UNKNOWN"

	/// Indicates that the notification has a `session` type and thus has the sessions style.
	case session = "TYPE_NEW_SESSION"

	/// Indicates that the notification has a `follower` type and thus has the follower style.
	case follower = "TYPE_NEW_FOLLOWER"

	/// The string value of a notification type.
	var stringValue: String {
		switch self {
		case .unknown:
			return ""
		case .session:
			return "Sessions"
		case .follower:
			return "Messages"
		}
	}

	var identifierString: String {
		switch self {
		case .unknown:
			return ""
		case .session:
			return "SessionNotificationCell"
		case .follower:
			return "MessageNotificationCell"
		}
	}
}
