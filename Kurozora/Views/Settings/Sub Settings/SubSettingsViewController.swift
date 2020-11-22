//
//  SubSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class SubSettingsViewController: KTableViewController {
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

// MARK: - UITableViewDelegate
extension SubSettingsViewController {
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
			settingsCell?.notificationGroupingValueLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell
		if settingsCell?.selectedView != nil {
			settingsCell?.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			settingsCell?.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			settingsCell?.primaryLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell?.notificationGroupingValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
}
