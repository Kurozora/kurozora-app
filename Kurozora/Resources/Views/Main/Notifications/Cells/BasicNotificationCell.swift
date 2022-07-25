//
//  BasicNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BasicNotificationCell: BaseNotificationCell {
	// MARK: - IBOutlets
	@IBOutlet weak var notificationIconImageView: UIImageView!
	@IBOutlet weak var chevronImageView: UIImageView!

	// MARK: - Functions
	override func configureCell(using userNotification: UserNotification, notificationType: KNotification.CustomType?) {
		super.configureCell(using: userNotification, notificationType: notificationType)
		self.chevronImageView.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

		self.notificationIconImageView.image = notificationType?.iconValue
	}
}
