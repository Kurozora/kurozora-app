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
	@IBOutlet weak var readStatusImageView: KImageView!

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	var notificationType: KNotification.CustomType?
	var userNotification: UserNotification!

	// MARK: - Functions
	func configureCell(using userNotification: UserNotification, notificationType: KNotification.CustomType?) {
		self.userNotification = userNotification
		self.notificationType = notificationType

		self.dateLabel.text = userNotification.attributes.createdAt.relativeToNow
		self.contentLabel.text = userNotification.attributes.description
		self.notificationTypeLabel.text = notificationType?.stringValue.uppercased()

		// Setup read status.
		self.updateReadStatus(for: userNotification)
	}

	/// Update the read status of the user notification.
	///
	/// - Parameter animation: A boolean value indicating whether the update should be animated.
	func updateReadStatus(for userNotification: UserNotification, with readStatus: ReadStatus? = nil, animated: Bool = false) {
		if let readStatus = readStatus {
			userNotification.attributes.readStatus = readStatus
		}
		self.readStatusImageView.isHidden = userNotification.attributes.readStatus == .read

		if animated {
			self.readStatusImageView.animateBounce()
		}
	}
}
