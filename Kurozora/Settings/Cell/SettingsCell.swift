//
//  SettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
	@IBOutlet weak var appIconImageView: UIImageView? {
		didSet {
			updateAppIcon()
			NotificationCenter.default.addObserver(self, selector: #selector(updateAppIcon), name: .KSAppIconDidChange, object: nil)
		}
	}
	@IBOutlet weak var cellTitle: UILabel? {
		didSet {
			self.cellTitle?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var cellSubTitle: UILabel? {
		didSet {
			self.cellSubTitle?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel? {
		didSet {
			self.usernameLabel?.text = Kurozora.shared.KDefaults["username"]
			self.usernameLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var profileImageView: UIImageView? {
		didSet {
			self.profileImageView?.image = User.currentUserProfileImage
			self.profileImageView?.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var cacheSizeLabel: UILabel? {
		didSet {
			self.cacheSizeLabel?.theme_textColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var selectedView: UIView? {
		didSet {
			self.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			self.selectedView?.clipsToBounds = true
			self.selectedView?.cornerRadius = 10
		}
	}
	@IBOutlet weak var bubbleView: UIView? {
		didSet {
			self.bubbleView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			self.bubbleView?.clipsToBounds = true
			self.bubbleView?.cornerRadius = 10
		}
	}
	@IBOutlet weak var chevronImageView: UIImageView? {
		didSet {
			self.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue
		}
	}
	@IBOutlet weak var notificationGroupingValueLabel: UILabel? {
		didSet {
			self.notificationGroupingValueLabel?.text = NotificationGroupStyle(rawValue: UserSettings.notificationsGrouping)?.stringValue
			self.notificationGroupingValueLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
			NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationValueLabels), name: .KSNotificationOptionsValueLabelsNotification, object: nil)
		}
	}
	@IBOutlet weak var bannerStyleValueLabel: UILabel? {
		didSet {
			self.bannerStyleValueLabel?.text = NotificationBannerStyle(rawValue: UserSettings.notificationsPersistent)?.stringValue
			self.bannerStyleValueLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
			NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationValueLabels), name: .KSNotificationOptionsValueLabelsNotification, object: nil)
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.selectionStyle = .none
	}

	// MARK: - Functions
	@objc func updateAppIcon() {
		self.appIconImageView?.image = UIImage(named: UserSettings.appIcon)
	}

	@objc func updateNotificationValueLabels() {
		self.notificationGroupingValueLabel?.text = NotificationGroupStyle(rawValue: UserSettings.notificationsGrouping)?.stringValue
		self.bannerStyleValueLabel?.text = NotificationBannerStyle(rawValue: UserSettings.notificationsPersistent)?.stringValue
	}
}
