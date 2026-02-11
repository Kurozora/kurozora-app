//
//  KNotification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

enum KNotification {}

// MARK: - AlertStyle
extension KNotification {
	/// List of notification alert styles
	///
	/// ```swift
	/// case basic = 0
	/// case icon = 1
	/// case status = 2
	/// ```
	enum AlertStyle: Int {
		/// The notification showed has a text only.
		case basic = 0

		/// The notification showed has both an icon on the left and a text.
		case icon

		/// The notification shown is a small/thin strip of text shown on top of the statusbar.
		case status
	}
}

// MARK: - GroupStyle
extension KNotification {
	/// List of notification group styles.
	///
	/// ```swift
	/// case automatic = 0
	/// case byType
	/// case off
	/// ```
	enum GroupStyle: Int, CaseIterable {
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
