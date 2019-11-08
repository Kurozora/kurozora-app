//
//  BaseNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwipeCellKit

class BaseNotificationCell: SwipeTableViewCell {
	// Head
	@IBOutlet weak var notificationTypeLabel: UILabel! {
		didSet {
			notificationTypeLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var dateLabel: UILabel! {
		didSet {
			dateLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
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

	var notificationType: NotificationType?
	var userNotificationsElement: UserNotificationsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let userNotificationsElement = userNotificationsElement else { return }

		if let creationDate = userNotificationsElement.creationDate {
			dateLabel.text = creationDate.timeAgo
		}

		if let notificationContent = userNotificationsElement.message {
			notificationTextLabel.text = notificationContent
		}

		updateReadStatus()
	}

	/**
		Update the read status of the notification.

		- Parameter animation: A boolean value indicating whether the update should be animated.
	*/
	func updateReadStatus(animated: Bool = false) {
		if let notificationIsRead = userNotificationsElement?.read {
			notificationMark.numberOfPages = notificationIsRead ? 0 : 1

			if animated {
				notificationMark.animateBounce()
			}
		}
	}
}
