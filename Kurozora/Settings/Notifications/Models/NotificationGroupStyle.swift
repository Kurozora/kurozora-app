//
//  NotificationGroupStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification group styles

	- case automatic = 0
	- case byType = 1
	- case off = 2
*/
enum NotificationGroupStyle: Int {
	case automatic = 0
	case byType
	case off

	var stringValue: String {
		switch self {
		case .automatic:
			return "Automatic"
		case .byType:
			return "By Type"
		case .off:
			return "Off"
		}
	}
}
