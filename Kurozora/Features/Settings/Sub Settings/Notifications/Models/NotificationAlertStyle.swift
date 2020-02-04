//
//  NotificationAlertStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension KNotification {
	/**
		List of notification alert styles

		```
		case basic = 0
		case icon = 1
		case status = 2
		```
	*/
	enum AlertStyle: Int {
		/// The notification showed has a text only.
		case basic = 0

		/// The notification showed has both an icon on the left and a text.
		case icon

		/// The notification shown is a small/thin strip of text shown on top of the statusbar.
		case status
	}
}
