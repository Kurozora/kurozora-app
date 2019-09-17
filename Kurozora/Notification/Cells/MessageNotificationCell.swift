//
//  MessageNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwipeCellKit
import Kingfisher

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

		if let profileImage = userNotificationsElement?.data?.profileImage, !profileImage.isEmpty {
			let profileImageUrl = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImageUrl!)
			profileImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_profile_image"), options: [.transition(.fade(0.2))])
		} else {
			profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
		}
	}
}
