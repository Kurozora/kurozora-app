//
//  NotificationGroupStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension KNotification {
	/// List of notification group styles.
	///
	/// ```
	/// case automatic = 0
	/// case byType
	/// case off
	/// ```
	enum GroupStyle: Int {
		/// Groups the notifications in sections by their date and time.
		case automatic = 0

		/// Groups the notifications in sections by their notification type.
		case byType

		/// Groups the notifications in one section in by their date and time.
		case off

		/// The string value of a notification group style.
		var stringValue: String {
			switch self {
			case .automatic:
				return Trans.automatic
			case .byType:
				return Trans.byType
			case .off:
				return Trans.off
			}
		}
	}
}
