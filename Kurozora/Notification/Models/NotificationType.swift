//
//  NotificationType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification types

	- case unknown = "TYPE_UNKNOWN"
	- case session = "TYPE_NEW_SESSION"
	- case follower = "TYPE_NEW_FOLLOWER"
*/
enum NotificationType: String {
	case unknown = "TYPE_UNKNOWN"
	case session = "TYPE_NEW_SESSION"
	case follower = "TYPE_NEW_FOLLOWER"

	func stringValue() -> String {
		switch self {
		case .unknown:
			return ""
		case .session:
			return "Sessions"
		case .follower:
			return "Messages"
		}
	}
}
