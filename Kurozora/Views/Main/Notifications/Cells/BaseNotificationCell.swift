//
//  BaseNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BaseNotificationCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var notificationTypeLabel: KSecondaryLabel!
	@IBOutlet weak var dateLabel: KSecondaryLabel!
	@IBOutlet weak var contentLabel: KLabel!
	@IBOutlet weak var readStatusImageView: UIImageView!

	// MARK: - Properties
	var notificationType: KNotification.CustomType?
	var userNotification: UserNotification! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		self.dateLabel.text = userNotification.attributes.createdAt.relativeToNow
		self.contentLabel.text = userNotification.attributes.description
		self.notificationTypeLabel.text = notificationType?.stringValue.uppercased()

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
		readStatusImageView.isHidden = self.userNotification.attributes.readStatus == .read

		if animated {
			readStatusImageView.animateBounce()
		}
	}
}
