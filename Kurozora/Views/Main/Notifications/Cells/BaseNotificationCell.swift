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
	var userNotification: UserNotification! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		// Configure date label.
		self.dateLabel.text = userNotification.attributes.createdAt.timeAgo

		// Configure text label.
		self.notificationTextLabel.text = userNotification.attributes.description

		// Configure notification type label.
		self.notificationTypeLabel.text = notificationType?.stringValue.uppercased()

		// Configure bubble view.
		self.bubbleView.backgroundColor = notificationType?.colorValue

		// Setup read status.
		updateReadStatus()
	}

	/**
		Update the read status of the user notification.

		- Parameter animation: A boolean value indicating whether the update should be animated.
	*/
	func updateReadStatus(with readStatus: ReadStatus? = nil, animated: Bool = false) {
		if let readStatus = readStatus {
			self.userNotification.attributes.readStatus = readStatus
		}
		notificationMark.numberOfPages = self.userNotification.attributes.readStatus == .read ? 0 : 1

		if animated {
			notificationMark.animateBounce()
		}
	}
}
