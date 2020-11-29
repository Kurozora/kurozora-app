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
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var titleLabel: KLabel!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		if let title = userNotification?.attributes.payload.username {
			titleLabel.text = title
		}

		if let profileImageURL = userNotification?.attributes.payload.profileImageURL {
			if let usernameInitials = userNotification?.attributes.payload.username?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.userProfile()!)
				profileImageView.setImage(with: profileImageURL, placeholder: placeholderImage)
			}
		}
	}
}
