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

class MessageNotificationCell: SwipeTableViewCell {
	// Header
	@IBOutlet weak var notificationTypeLabel: UILabel! {
		didSet {
			notificationTypeLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var dateLabel: UILabel! {
		didSet {
			dateLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var notificationIconImageView: UIImageView!

	// Body
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var notificationTitleLabel: UILabel!
	@IBOutlet weak var notificationTextLabel: UILabel!

	var notificationsElement: UserNotificationsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let notificationsElement = notificationsElement else { return }
		if let title = notificationsElement.data?.name {
			notificationTitleLabel.text = title
		}

		if let profileImage = notificationsElement.data?.profileImage, !profileImage.isEmpty {
			let profileImageUrl = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImageUrl!)
			profileImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_profile_image"), options: [.transition(.fade(0.2))])
		} else {
			profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
		}

		if let creationDate = notificationsElement.creationDate {
			dateLabel.text = Date.timeAgo(creationDate)
		}

		if let notificationContent = notificationsElement.message {
			notificationTextLabel.text = notificationContent
		}
	}
}
