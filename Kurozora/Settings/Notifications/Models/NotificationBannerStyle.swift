//
//  NotificationBannerStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification banner styles

	- case temporary = 0
	- case persistent = 1
*/
enum NotificationBannerStyle: Int {
	case temporary = 0
	case persistent

	var stringValue: String {
		switch self {
		case .temporary:
			return "Temporary"
		case .persistent:
			return "Persistent"
		}
	}
}
