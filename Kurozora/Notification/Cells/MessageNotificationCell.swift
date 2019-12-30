//
//  MessageNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwipeCellKit

class MessageNotificationCell: BaseNotificationCell {
	// Body
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var notificationTitleLabel: UILabel!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		if let title = userNotificationsElement?.data?.name {
			notificationTitleLabel.text = title
		}

		if let profileImage = userNotificationsElement?.data?.profileImage {
			if let usernameInitials = userNotificationsElement?.data?.name?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: #imageLiteral(resourceName: "default_profile_image"))
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}
	}
}
