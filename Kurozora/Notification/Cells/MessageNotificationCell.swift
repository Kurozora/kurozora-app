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
	@IBOutlet weak var notificationDateLabel: UILabel! {
		didSet {
			notificationDateLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var notificationIconImageView: UIImageView!

	// Body
	@IBOutlet weak var notificationProfileImageView: UIImageView! {
		didSet {
			notificationProfileImageView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var notificationTitleLabel: UILabel!
	@IBOutlet weak var notificationTextLabel: UILabel!

	var notificationsElement: UserNotificationsElement? {
		didSet {
			setup()
		}
	}

	fileprivate func setup() {
		guard let notificationsElement = notificationsElement else { return }
		if let title = notificationsElement.data?.name {
			notificationTitleLabel.text = title
		}

		if let avatar = notificationsElement.data?.avatar, avatar != "" {
			let avatarUrl = URL(string: avatar)
			let resource = ImageResource(downloadURL: avatarUrl!)
			notificationProfileImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			notificationProfileImageView.image = #imageLiteral(resourceName: "default_avatar")
		}

		if let creationDate = notificationsElement.creationDate {
			notificationDateLabel.text = Date.timeAgo(creationDate)
		}

		if let notificationContent = notificationsElement.message {
			notificationTextLabel.text = notificationContent
		}
	}
}
