//
//  NotificationType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

enum KNotification {
	/**
		List of custom notification types.

		```
		case session = "NewSession"
		case follower = "NewFollower"
		case other
		```
	*/
	enum CustomType: String {
		/// Indicates that the notification has a `session` type and thus has the sessions style.
		case session = "NewSession"

		/// Indicates that the notification has a `follower` type and thus has the follower style.
		case follower = "NewFollower"

		/// Indicates that the notification has no specific type and thus has the default style.
		case other

		/// The string value of a notification type.
		var stringValue: String {
			switch self {
			case .session:
				return "Sessions"
			case .follower:
				return "Messages"
			case .other:
				return "Other"
			}
		}

		/// The string value of a notification type cell.
		var identifierString: String {
			switch self {
			case .session:
				return R.reuseIdentifier.sessionNotificationCell.identifier
			case .follower:
				return R.reuseIdentifier.messageNotificationCell.identifier
			case .other:
				return R.reuseIdentifier.baseNotificationCell.identifier
			}
		}
	}
}
