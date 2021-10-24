//
//  BrowserSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BrowserSettingsTableViewController: SubSettingsViewController {
}

// MARK: - UITableViewDataSource
extension BrowserSettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 0 : KBrowser.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.iconTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.iconTableViewCell.identifier)")
		}
		let defaultBrowser = KBrowser.allCases[indexPath.row]
		let selectedDefaultBrowser = UserSettings.defaultBrowser
		iconTableViewCell.browser = defaultBrowser
		iconTableViewCell.setSelected(defaultBrowser == selectedDefaultBrowser)
		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 0 {
			return "Choose a default browser in which web links will be opened. If you don't have the app installed then the links will open inside Safari as a fallback."
		}

		return nil
	}
}

// MARK: - UITableViewDelegate
extension BrowserSettingsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UserSettings.set(indexPath.item, forKey: .defaultBrowser)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension BrowserSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
