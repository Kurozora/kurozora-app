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
		guard let BrowserSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.browserSettingsTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.browserSettingsTableViewCell.identifier)")
		}
		return BrowserSettingsTableViewCell
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let browserSettingsTableViewCell = cell as? BrowserSettingsTableViewCell {
			browserSettingsTableViewCell.browser = KBrowser.allCases[indexPath.row]
		}
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
		if let browserSettingsTableViewCell = tableView.cellForRow(at: indexPath) as? BrowserSettingsTableViewCell {
			UserSettings.set(browserSettingsTableViewCell.browser?.rawValue, forKey: .defaultBrowser)
			tableView.reloadData()
		}
	}
}
