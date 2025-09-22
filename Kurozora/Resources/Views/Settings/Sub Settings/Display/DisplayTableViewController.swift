//
//  DisplayTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class DisplayTableViewController: SubSettingsViewController {}

// MARK: - UITableViewDataSource
extension DisplayTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			if UserSettings.automaticDarkTheme {
				return 3
			} else {
				return 2
			}
		default:
			return super.tableView(tableView, numberOfRowsInSection: section)
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0, let displaySettingsCell = super.tableView(tableView, cellForRowAt: indexPath) as? DisplaySettingsCell {
			if let appAppearanceOption = AppAppearanceOption(rawValue: UserSettings.appearanceOption) {
				displaySettingsCell.updateAppAppearanceOptions(with: appAppearanceOption)
				displaySettingsCell.delegate = self
			}
			return displaySettingsCell
		}

		return super.tableView(tableView, cellForRowAt: indexPath)
	}
}

// MARK: - DisplaySettingsCellDelegate
extension DisplayTableViewController: DisplaySettingsCellDelegate {
	func displaySettingsCell(_ cell: DisplaySettingsCell, automaticDarkThemeEnabled: Bool) {
		self.tableView.reloadData()
	}
}
