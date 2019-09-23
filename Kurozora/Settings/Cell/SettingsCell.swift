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
			self.usernameLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var profileImageView: UIImageView? {
		didSet {
			self.profileImageView?.theme_borderColor = KThemePicker.borderColor.rawValue
			self.profileImageView?.theme_tintColor = KThemePicker.borderColor.rawValue
			NotificationCenter.default.addObserver(self, selector: #selector(updateAccountCell), name: .KUserIsSignedInDidChange, object: nil)
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
	/// Updates the account cell depending on the user's loggin state.
	@objc func updateAccountCell() {
		self.profileImageView?.image = User.isSignedIn ? User.currentUserProfileImage : #imageLiteral(resourceName: "profile")
		self.usernameLabel?.text = User.isSignedIn ? Kurozora.shared.KDefaults["username"] : "Sign in to your Kurozora account"
		self.cellSubTitle?.text = User.isSignedIn ? "Kurozora ID" : "Setup Kurozora ID and more."
		self.chevronImageView?.isHidden = !User.isSignedIn
	}

	/// Updates the app icon image with the one selected by the user.
	@objc func updateAppIcon() {
		self.appIconImageView?.image = UIImage(named: UserSettings.appIcon)
	}

	/// Updates the notification value labels with the respective options selected by the user.
	@objc func updateNotificationValueLabels() {
		self.notificationGroupingValueLabel?.text = NotificationGroupStyle(rawValue: UserSettings.notificationsGrouping)?.stringValue
		self.bannerStyleValueLabel?.text = NotificationBannerStyle(rawValue: UserSettings.notificationsPersistent)?.stringValue
	}
}
