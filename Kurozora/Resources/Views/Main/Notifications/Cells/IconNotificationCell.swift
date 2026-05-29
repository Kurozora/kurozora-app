//
//  IconNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class IconNotificationCell: BasicNotificationCell {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var borderView: BorderView!
	@IBOutlet weak var titleLabel: KLabel!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.profileImageView.layer.borderWidth = 0
		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	// MARK: - Functions
	override func configureCell(using userNotification: UserNotification) {
		super.configureCell(using: userNotification)
		self.titleLabel.text = userNotification.attributes.payload.username

		if let profileImageURL = userNotification.attributes.payload.profileImageURL {
			if let usernameInitials = userNotification.attributes.payload.username?.initials.capitalized {
				let placeholderImage = usernameInitials.toImage(placeholder: .Placeholders.userProfile)
				self.profileImageView.setImage(with: profileImageURL, placeholder: placeholderImage)
			}
		}
	}
}
