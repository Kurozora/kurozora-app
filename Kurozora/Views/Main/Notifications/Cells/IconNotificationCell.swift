//
//  IconNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class IconNotificationCell: BasicNotificationCell {
	// MARK: - IBOutlets
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

		if let title = userNotificationsElement?.data?.username {
			notificationTitleLabel.text = title
		}

		if let profileImage = userNotificationsElement?.data?.profileImage {
			if let usernameInitials = userNotificationsElement?.data?.username?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.profile_image()!)
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}
	}
}
