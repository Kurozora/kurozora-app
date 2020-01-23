//
//  BrowserSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BrowserSettingsTableViewController: KTableViewController {
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
extension BrowserSettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 0 : KBrowser.all.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let BrowserSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BrowserSettingsTableViewCell", for: indexPath) as! BrowserSettingsTableViewCell
		return BrowserSettingsTableViewCell
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let browserSettingsTableViewCell = cell as? BrowserSettingsTableViewCell {
			browserSettingsTableViewCell.browser = KBrowser.all[indexPath.row]
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

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let browserSettingsTableViewCell = tableView.cellForRow(at: indexPath) as? BrowserSettingsTableViewCell {
			browserSettingsTableViewCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			browserSettingsTableViewCell.primaryTitleLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let browserSettingsTableViewCell = tableView.cellForRow(at: indexPath) as? BrowserSettingsTableViewCell {
			browserSettingsTableViewCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			browserSettingsTableViewCell.primaryTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
}
