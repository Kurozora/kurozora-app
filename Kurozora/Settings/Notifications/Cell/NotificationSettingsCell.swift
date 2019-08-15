//
//  NotificationSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

class NotificationSettingsCell: SettingsCell {
	// Device image views
	@IBOutlet weak var basicNotificationDeviceImageView: UIImageView! {
		didSet {
			if UIDevice.isPad {
				basicNotificationDeviceImageView.image = #imageLiteral(resourceName: "notification_basic_ipad")
			} else {
				basicNotificationDeviceImageView.image = #imageLiteral(resourceName: "notification_basic_iphone")
			}
		}
	}
	@IBOutlet weak var iconNotificationDeviceImageView: UIImageView! {
		didSet {
			if UIDevice.isPad {
				iconNotificationDeviceImageView.image = #imageLiteral(resourceName: "notification_icon_ipad")
			} else {
				iconNotificationDeviceImageView.image = #imageLiteral(resourceName: "notification_icon_iphone")
			}
		}
	}
	@IBOutlet weak var statusBarNotificationDeviceImageView: UIImageView! {
		didSet {
			if UIDevice.isPad {
				statusBarNotificationDeviceImageView.image = #imageLiteral(resourceName: "notification_statusbar_ipad")
			} else {
				statusBarNotificationDeviceImageView.image = #imageLiteral(resourceName: "notification_statusbar_iphone")
			}
		}
	}

	// Selected image views
	@IBOutlet weak var basicNotificationSelectedImageView: UIImageView! {
		didSet {
			basicNotificationSelectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
			basicNotificationSelectedImageView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var iconNotificationSelectedImageView: UIImageView! {
		didSet {
			iconNotificationSelectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
			iconNotificationSelectedImageView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var statusBarNotificationSelectedImageView: UIImageView! {
		didSet {
			statusBarNotificationSelectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
			statusBarNotificationSelectedImageView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	// Titles
	@IBOutlet weak var basicNotificationTitleLabel: UILabel! {
		didSet {
			basicNotificationTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var iconNotificationTitleLabel: UILabel! {
		didSet {
			iconNotificationTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var statusBarNotificationTitleLabel: UILabel! {
		didSet {
			statusBarNotificationTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	// Buttons
	@IBOutlet weak var basicNotificationButton: UIButton! {
		didSet {
			basicNotificationButton.tag = 0
		}
	}
	@IBOutlet weak var iconNotificationButton: UIButton! {
		didSet {
			iconNotificationButton.tag = 1
		}
	}
	@IBOutlet weak var statusBarNotificationButton: UIButton! {
		didSet {
			statusBarNotificationButton.tag = 2
		}
	}

	// MARK: - Functions
	func updateAlertType(with type: Int) {
		switch type {
		case 0:
			basicNotificationSelectedImageView.borderWidth = 0
			iconNotificationSelectedImageView.borderWidth = 2
			statusBarNotificationSelectedImageView.borderWidth = 2

			basicNotificationSelectedImageView.image = #imageLiteral(resourceName: "check_circle")
			iconNotificationSelectedImageView.image = nil
			statusBarNotificationSelectedImageView.image = nil
		case 1:
			iconNotificationSelectedImageView.borderWidth = 0
			basicNotificationSelectedImageView.borderWidth = 2
			statusBarNotificationSelectedImageView.borderWidth = 2

			iconNotificationSelectedImageView.image = #imageLiteral(resourceName: "check_circle")
			basicNotificationSelectedImageView.image = nil
			statusBarNotificationSelectedImageView.image = nil
		case 2:
			statusBarNotificationSelectedImageView.borderWidth = 0
			basicNotificationSelectedImageView.borderWidth = 2
			iconNotificationSelectedImageView.borderWidth = 2

			statusBarNotificationSelectedImageView.image = #imageLiteral(resourceName: "check_circle")
			basicNotificationSelectedImageView.image = nil
			iconNotificationSelectedImageView.image = nil
		default: break
		}
	}

	// MARK: - IBActions
	@IBAction func notificationButtonTapped(_ sender: UIButton) {
		UserSettings.set(sender.tag, forKey: .alertType)
		updateAlertType(with: sender.tag)
	}
}
