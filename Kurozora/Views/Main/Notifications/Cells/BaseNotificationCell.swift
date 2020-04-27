//
//  BaseNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwipeCellKit

class BaseNotificationCell: SwipeTableViewCell {
	// MARK: - IBOutlets
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
	@IBOutlet weak var notificationMark: UIPageControl! {
		didSet {
			notificationMark.theme_currentPageIndicatorTintColor = KThemePicker.tintColor.rawValue
		}
	}

	// Body
	@IBOutlet weak var notificationTextLabel: UILabel!
	@IBOutlet weak var bubbleView: UIView!

	// MARK: - Properties
	var notificationType: KNotification.CustomType?
	var userNotificationElement: UserNotificationElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let userNotificationElement = userNotificationElement else { return }

		// Configure date label.
		if let creationDate = userNotificationElement.creationDate {
			self.dateLabel.text = creationDate.timeAgo
		}

		// Configure text label.
		if let notificationContent = userNotificationElement.message {
			self.notificationTextLabel.text = notificationContent
		}

		// Configure notification type label.
		self.notificationTypeLabel.text = notificationType?.stringValue

		// Configure bubble view.
		self.bubbleView.backgroundColor = notificationType?.colorValue

		// Setup read status.
		updateReadStatus()
	}

	/**
		Update the read status of the notification.

		- Parameter animation: A boolean value indicating whether the update should be animated.
	*/
	func updateReadStatus(animated: Bool = false) {
		notificationMark.numberOfPages = userNotificationElement?.readStatus == .read ? 0 : 1

		if animated {
			notificationMark.animateBounce()
		}
	}
}
