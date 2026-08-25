//
//  SettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Kingfisher
import KurozoraKit
import UIKit

class SettingsCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var iconImageViewContainer: UIView?
	@IBOutlet weak var iconImageView: IconImageView?
	@IBOutlet weak var primaryLabel: KLabel?
	@IBOutlet weak var secondaryLabel: KSecondaryLabel?
	@IBOutlet weak var detailLabel: KSecondaryLabel?
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

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Functions
	/// Configure the cell with the given title.
	func configure(title: String?, subtitle: String? = nil, detail: String? = nil, icon: UIImage? = nil, isEnabled: Bool = true) {
		self.primaryLabel?.text = title

		self.secondaryLabel?.text = subtitle
		self.secondaryLabel?.isHidden = subtitle == nil

		self.detailLabel?.text = detail
		self.detailLabel?.isHidden = detail == nil

		self.iconImageView?.image = icon
		self.iconImageViewContainer?.isHidden = icon == nil

		self.primaryLabel?.theme_textColor = isEnabled ? KThemePicker.tableViewCellTitleTextColor.rawValue : KThemePicker.subTextColor.rawValue
		self.contentView.alpha = isEnabled ? 1.0 : 0.5
		self.selectionStyle = isEnabled ? .default : .none
	}

	/// Configure the cell with the given details.
	func configure(using sectionRow: SettingsTableViewController.Row?) {
		self.configure(title: sectionRow?.primaryStringValue, subtitle: sectionRow?.secondaryStringValue, icon: sectionRow?.imageValue)

		switch sectionRow {
		case .account:
			if let iconImageView = self.iconImageView {
				User.current?.attributes.profileImage(imageView: iconImageView)
			}
		case .motion:
			self.updateSplashScreenAnimation()
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateSplashScreenAnimation), name: .KSSplashScreenAnimationDidChange, object: nil)
		case .browser:
			self.updateAppBrowser()
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppBrowser), name: .KSAppBrowserDidChange, object: nil)
		case .cache:
			Task { [weak self] in
				guard let self = self else { return }
				self.detailLabel?.text = await self.calculateCache()
			}
		case .icon:
			self.updateAppIcon()
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppIcon), name: .KSAppIconDidChange, object: nil)
		case .theme:
			self.updateAppTheme()
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
			self.detailLabel?.isHidden = self.reuseIdentifier == SettingsCell.reuseID
		case .chevron:
			self.detailLabel?.isHidden = self.reuseIdentifier == SettingsCell.reuseID
			self.chevronImageView?.isHidden = false
		case .label:
			self.chevronImageView?.isHidden = true
			self.detailLabel?.isHidden = false
		case .labelAndChevron:
			self.detailLabel?.isHidden = self.reuseIdentifier == SettingsCell.reuseID
			self.chevronImageView?.isHidden = false
			self.detailLabel?.isHidden = false
		}
	}
}

// MARK: - Helpers
extension SettingsCell {
	/// Calculates the total cache size across all components and returns a formatted string.
	fileprivate func calculateCache() async -> String {
		let richLink = RichLink.shared
		let richLinkBytes = await Task.detached(priority: .userInitiated) {
			richLink.cacheSize()
		}.value

		let imageCacheBytes: UInt
		do {
			imageCacheBytes = try await ImageCache.default.diskStorageSize
		} catch {
			print("----- Cache size calculation error: \(error)")
			imageCacheBytes = 0
		}

		let totalBytes = richLinkBytes + imageCacheBytes
		let sizeInMiB = Double(totalBytes) / 1024 / 1024
		return String(format: "%.2f", sizeInMiB) + "MiB"
	}

	/// Updates the app browser text with the one selected by the user.
	@objc func updateAppBrowser() {
		self.detailLabel?.text = UserSettings.defaultBrowser.shortStringValue
	}

	/// Updates the app icon image with the one selected by the user.
	@objc func updateAppIcon() {
		let appIcon = UserSettings.appIcon
		self.iconImageView?.image = .appIconPreview(named: appIcon)
		self.detailLabel?.text = appIcon == UserSettings.defaultAppIcon ? L10n.`default` : appIcon
	}

	/// Updates the app theme text with the one selected by the user.
	@objc func updateAppTheme() {
		let themeName = UserSettings.currentThemeName
		self.detailLabel?.text = (themeName.isEmpty || themeName == KThemeStyle.default.stringValue) ? L10n.`default` : KThemeStyle.localizedName(forStoredName: themeName)
	}

	/// Updates the app theme text with the one selected by the user.
	@objc func updateSplashScreenAnimation() {
		self.detailLabel?.text = UserSettings.currentSplashScreenAnimation.titleValue
	}
}
