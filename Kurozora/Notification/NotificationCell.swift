//
//  NotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwipeCellKit

class MessageNotificationCell: SwipeTableViewCell {
    // Header
	@IBOutlet weak var notificationDate: UILabel! {
		didSet {
			notificationDate.theme_textColor = KThemePicker.accentColor.rawValue
		}
	}
	@IBOutlet weak var notificationType: UILabel! {
		didSet {
			notificationType.theme_textColor = KThemePicker.accentColor.rawValue
		}
	}
    @IBOutlet weak var notificationIcon: UIImageView!
    
    // Body
	@IBOutlet weak var notificationProfileImage: UIImageView!
	@IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationTextLabel: UILabel!
}

class SessionNotificationCell: SwipeTableViewCell {
    // Header
	@IBOutlet weak var notificationDate: UILabel! {
		didSet {
			notificationDate.theme_textColor = KThemePicker.accentColor.rawValue
		}
	}
	@IBOutlet weak var notificationType: UILabel! {
		didSet {
			notificationType.theme_textColor = KThemePicker.accentColor.rawValue
		}
	}
    @IBOutlet weak var notificationIcon: UIImageView!
    
    // Body
	@IBOutlet weak var notificationTextLabel: UILabel!
}

class TitleNotificationCell: UITableViewCell {
	@IBOutlet weak var notificationTitleLabel: UILabel! {
		didSet {
			notificationTitleLabel.theme_textColor = KThemePicker.accentColor.rawValue
		}
	}
}
