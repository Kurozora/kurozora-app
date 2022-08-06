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

	// MARK: - Functions
	func configureCell(using userNotification: UserNotification) {
		self.dateLabel.text = userNotification.attributes.createdAt.relativeToNow
		self.contentLabel.text = userNotification.attributes.description
		self.notificationTypeLabel.text = userNotification.attributes.type.stringValue.uppercased()
		self.readStatusImageView.isHidden = userNotification.attributes.readStatus == .read
	}
}
