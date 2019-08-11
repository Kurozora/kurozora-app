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
	@IBOutlet weak var notificationMark: UIPageControl! {
		didSet {
			notificationMark.theme_currentPageIndicatorTintColor = KThemePicker.tintColor.rawValue
		}
	}

	// Body
	@IBOutlet weak var notificationTextLabel: UILabel!

	var notificationsElement: UserNotificationsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let notificationsElement = notificationsElement else { return }
		if let creationDate = notificationsElement.creationDate {
			notificationDateLabel.text = Date.timeAgo(creationDate)
		}

		if let notificationContent = notificationsElement.message {
			notificationTextLabel.text = notificationContent
		}

		updateReadStatus()
	}

	/**
		Update the read status of the notification.

		- Parameter animation: A boolean value indicating whether the update should be animated.
	*/
	func updateReadStatus(animated: Bool = false) {
		guard let notificationsElement = notificationsElement else { return }
		if let notificationIsRead = notificationsElement.read {
			notificationMark.numberOfPages = notificationIsRead ? 0 : 1

			if animated {
				notificationMark.animateBounce()
			}
		}
	}
}
