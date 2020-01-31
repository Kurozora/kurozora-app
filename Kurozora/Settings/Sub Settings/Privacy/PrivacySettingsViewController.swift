//
//  PrivacySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class PrivacySettingsViewController: KTableViewController {
	// MARK: - Properties
	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true
	}
}

// MARK: - UITableViewDataSource
extension PrivacySettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath {
		case [0, 0]:
			#if targetEnvironment(macCatalyst)
			let settingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")
			#else
			let settingsUrl = URL(string: UIApplication.openSettingsURLString)
			#endif

			UIApplication.shared.kOpen(settingsUrl)
		default: return
		}
	}
}

// MARK: - UITableViewDelegate
extension PrivacySettingsViewController {
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
			headerView.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell
		if settingsCell?.selectedView != nil {
			settingsCell?.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			settingsCell?.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

			settingsCell?.primaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			settingsCell?.bannerStyleValueLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			settingsCell?.notificationGroupingValueLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell
		if settingsCell?.selectedView != nil {
			settingsCell?.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			settingsCell?.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			settingsCell?.primaryLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell?.bannerStyleValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			settingsCell?.notificationGroupingValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
}
