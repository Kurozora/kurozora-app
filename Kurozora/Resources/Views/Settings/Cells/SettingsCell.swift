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
	@IBOutlet weak var iconImageView: UIImageView? {
		didSet {
			self.iconImageView?.layerBorderColor = UIColor.white.withAlphaComponent(0.2)
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
			NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationValueLabels), name: .KSNotificationOptionsValueLabelsNotification, object: nil)
		}
	}

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
		case .icon:
			NotificationCenter.default.addObserver(self, selector: #selector(updateAppIcon), name: .KSAppIconDidChange, object: nil)
		case .cache:
			self.calculateCache(withSuccess: { [weak self] cacheSize in
				guard let self = self else { return }
				DispatchQueue.main.async {
					self.secondaryLabel?.text = cacheSize
				}
			})
		default:
			NotificationCenter.default.removeObserver(self, name: .KSAppIconDidChange, object: nil)
		}

		switch sectionRow?.accessoryValue ?? .none {
		case .none:
			chevronImageView?.isHidden = true
			secondaryLabel?.isHidden = reuseIdentifier == R.reuseIdentifier.settingsCell.identifier
		case .chevron:
			secondaryLabel?.isHidden = reuseIdentifier == R.reuseIdentifier.settingsCell.identifier
			chevronImageView?.isHidden = false
		case .label:
			chevronImageView?.isHidden = true
			secondaryLabel?.isHidden = false
		}
	}

	/// Calculate the amount of data that is cached by the app.
	///
	/// - Parameters:
	///    - successHandler: A closure that returns a string representing the amount of data that is cached by the app.
	///    - cacheString: The string representing the amount of data that is cached by the app.
	fileprivate func calculateCache(withSuccess successHandler: @escaping (_ cacheString: String) -> Void) {
		ImageCache.default.calculateDiskStorageSize { result in
			switch result {
			case .success(let size):
				// Convert from bytes to mebibytes (2^20)
				let sizeInMiB = Double(size) / 1024 / 1024
				successHandler(String(format: "%.2f", sizeInMiB) + "MiB")
			case .failure(let error):
				print("Cache size calculation error: \(error)")
				successHandler("0.00MiB")
			}
		}
	}

	/// Updates the app icon image with the one selected by the user.
	@objc func updateAppIcon() {
		self.iconImageView?.image = UIImage(named: UserSettings.appIcon)
	}

	/// Updates the notification value labels with the respective options selected by the user.
	@objc func updateNotificationValueLabels() {
		self.notificationGroupingValueLabel?.text = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping)?.stringValue
	}
}
