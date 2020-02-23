//
//  NotificationBannerStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension KNotification {
	/**
		List of notification banner styles.

		```
		case temporary = 0
		case persistent = 1
		```
	*/
	enum BannerStyle: Int {
		/// Indicates that the notifications shown should stay for a temporary amount of time before being dismissed.
		case temporary = 0

		/// Indicates that the notifications shown should stay until the user dismisses them manually.
		case persistent

		/// The string value of a notification banner style.
		var stringValue: String {
			switch self {
			case .temporary:
				return "Temporary"
			case .persistent:
				return "Persistent"
			}
		}
	}
}
