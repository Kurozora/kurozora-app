//
//  BrowserSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BrowserSettingsTableViewController: SubSettingsViewController {
	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the table view
	private func sharedInit() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
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
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID)")
		}
		let defaultBrowser = KBrowser.allCases[indexPath.row]
		let selectedDefaultBrowser = UserSettings.defaultBrowser
		iconTableViewCell.configureCell(using: defaultBrowser)
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
		NotificationCenter.default.post(name: .KSAppBrowserDidChange, object: nil)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension BrowserSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
