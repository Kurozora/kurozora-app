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
			profileImageView.borderColor = UIColor.white.withAlphaComponent(0.2)
		}
	}
	@IBOutlet weak var notificationTitleLabel: UILabel!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		if let title = userNotificationElement?.data?.username {
			notificationTitleLabel.text = title
		}

		if let profileImage = userNotificationElement?.data?.profileImage {
			if let usernameInitials = userNotificationElement?.data?.username?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.userProfile()!)
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}
	}
}
