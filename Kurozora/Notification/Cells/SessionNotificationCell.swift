//
//  SessionNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwipeCellKit

class SessionNotificationCell: SwipeTableViewCell {
	// Header
	@IBOutlet weak var notificationTypeLabel: UILabel! {
		didSet {
			notificationTypeLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var notificationDateLabel: UILabel! {
		didSet {
			notificationDateLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var notificationIconImageView: UIImageView!

	// Body
	@IBOutlet weak var notificationTextLabel: UILabel!

	var notificationsElement: UserNotificationsElement? {
		didSet {
			setup()
		}
	}

	// MARK: - Functions

	fileprivate func setup() {
		guard let notificationsElement = notificationsElement else { return }
		if let creationDate = notificationsElement.creationDate {
			notificationDateLabel.text = Date.timeAgo(creationDate)
		}

		if let notificationContent = notificationsElement.message {
			notificationTextLabel.text = notificationContent
		}

	}
}
