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
		self.headerImage = .Icons.browser
		self.headerTitle = L10n.browser
		self.headerDescription = L10n.browserHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - KTableViewDataSource
extension BrowserSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			IconTableViewCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension BrowserSettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1 + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard self.contentSection(for: section) != nil else { return 1 }
		return KBrowser.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

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
		guard self.contentSection(for: section) != nil else { return nil }
		return L10n.browserSettingsFooter
	}
}

// MARK: - UITableViewDelegate
extension BrowserSettingsTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let contentSection = self.contentSection(for: section) else { return .leastNormalMagnitude }
		return super.tableView(tableView, heightForHeaderInSection: contentSection)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard self.contentSection(for: indexPath.section) != nil else { return }

		UserSettings.set(indexPath.item, forKey: .defaultBrowser)
		NotificationCenter.default.post(name: .KSAppBrowserDidChange, object: nil)
		tableView.reloadData()
	}
}
