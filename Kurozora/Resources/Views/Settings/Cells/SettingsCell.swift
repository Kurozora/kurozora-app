//
//  SettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Kingfisher

class SettingsCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var iconImageView: KImageView? {
		didSet {
			self.iconImageView?.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
		}
	}
	@IBOutlet weak var primaryLabel: KLabel?
	@IBOutlet weak var secondaryLabel: KSecondaryLabel?
	@IBOutlet weak var selectedView: UIView? {
		didSet {
			self.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var chevronImageView: UIImageView? {
		didSet {
			self.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue
		}
	}
	@IBOutlet weak var notificationGroupingValueLabel: KSecondaryLabel? {
		didSet {
			self.notificationGroupingValueLabel?.text = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping)?.stringValue
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotificationValueLabels), name: .KSNotificationOptionsValueLabelsNotification, object: nil)
		}
	}
	@IBOutlet weak var popupButton: KButton?

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using sectionRow: SettingsTableViewController.Row?) {
		self.iconImageView?.image = sectionRow?.imageValue
		self.primaryLabel?.text = sectionRow?.primaryStringValue
		self.secondaryLabel?.text = sectionRow?.secondaryStringValue

		switch sectionRow {
		case .motion:
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateSplashScreenAnimation), name: .KSSplashScreenAnimationDidChange, object: nil)
		case .browser:
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppBrowser), name: .KSAppBrowserDidChange, object: nil)
		case .cache:
			self.calculateCache(withSuccess: { [weak self] cacheSize in
				guard let self = self else { return }
				DispatchQueue.main.async {
					self.secondaryLabel?.text = cacheSize
				}
			})
		case .icon:
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppIcon), name: .KSAppIconDidChange, object: nil)
		case .theme:
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppTheme), name: .KSAppAppearanceDidChange, object: nil)
		default:
			NotificationCenter.default.removeObserver(self, name: .KSSplashScreenAnimationDidChange, object: nil)
			NotificationCenter.default.removeObserver(self, name: .KSAppBrowserDidChange, object: nil)
			NotificationCenter.default.removeObserver(self, name: .KSAppAppearanceDidChange, object: nil)
			NotificationCenter.default.removeObserver(self, name: .KSAppIconDidChange, object: nil)
		}

		switch sectionRow?.accessoryValue ?? .none {
		case .none:
			self.chevronImageView?.isHidden = true
			self.secondaryLabel?.isHidden = reuseIdentifier == R.reuseIdentifier.settingsCell.identifier
		case .chevron:
			self.secondaryLabel?.isHidden = reuseIdentifier == R.reuseIdentifier.settingsCell.identifier
			self.chevronImageView?.isHidden = false
		case .label:
			self.chevronImageView?.isHidden = true
			self.secondaryLabel?.isHidden = false
		case .labelAndChevron:
			self.secondaryLabel?.isHidden = reuseIdentifier == R.reuseIdentifier.settingsCell.identifier
			self.chevronImageView?.isHidden = false
			self.secondaryLabel?.isHidden = false
		}
	}

	/// Calculate the amount of data that is cached by the app.
	///
	/// - Parameters:
	///    - successHandler: A closure that returns a string representing the amount of data that is cached by the app.
	///    - cacheString: The string representing the amount of data that is cached by the app.
	fileprivate func calculateCache(withSuccess successHandler: @escaping (_ cacheString: String) -> Void) {
		ImageCache.default.calculateDiskStorageSize { result in
			let rickLinkCacheSize = RichLink.shared.cacheSize()
			let totalCacheSize: UInt

			switch result {
			case .success(let imageCacheSize):
				totalCacheSize = rickLinkCacheSize + imageCacheSize
			case .failure(let error):
				print("----- Cache size calculation error: \(error)")
				totalCacheSize = rickLinkCacheSize
			}

			// Convert from bytes to mebibytes (2^20)
			let sizeInMiB = Double(totalCacheSize) / 1024 / 1024
			successHandler(String(format: "%.2f", sizeInMiB) + "MiB")
		}
	}

	/// Updates the app browser text with the one selected by the user.
	@objc func updateAppBrowser() {
		self.secondaryLabel?.text = UserSettings.defaultBrowser.shortStringValue
	}

	/// Updates the app icon image with the one selected by the user.
	@objc func updateAppIcon() {
		self.iconImageView?.image = UIImage(named: UserSettings.appIcon)
		self.secondaryLabel?.text = UserSettings.appIcon.replacingOccurrences(of: " Preview", with: "")
	}

	/// Updates the app theme text with the one selected by the user.
	@objc func updateAppTheme() {
		self.secondaryLabel?.text = UserSettings.currentThemeName
	}

	/// Updates the app theme text with the one selected by the user.
	@objc func updateSplashScreenAnimation() {
		self.secondaryLabel?.text = UserSettings.currentSplashScreenAnimation.titleValue
	}

	/// Updates the notification value labels with the respective options selected by the user.
	@objc func updateNotificationValueLabels() {
		self.notificationGroupingValueLabel?.text = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping)?.stringValue
	}
}
