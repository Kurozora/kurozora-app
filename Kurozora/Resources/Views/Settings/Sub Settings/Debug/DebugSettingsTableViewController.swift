//
//  DebugSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class DebugSettingsTableViewController: SubSettingsViewController {
	// MARK: - Properties
	private var sectionItems: [Section: [(key: String, value: String)]] = [:]

	private var totalItemCount: Int {
		return self.sectionItems.values.reduce(0) { $0 + $1.count }
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.key
		self.headerTitle = L10n.keysManager
		self.headerDescription = L10n.keysManagerHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.reloadSections()
		self.toggleEmptyDataView()
	}

	// MARK: - Functions
	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.keyRing)
		self.emptyBackgroundView.configureLabels(title: L10n.debugNoKeysTitle, detail: L10n.debugNoKeysDetail)

		self.tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to `totalItemCount`.
	func toggleEmptyDataView() {
		if self.totalItemCount == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	private func reloadSections() {
		self.sectionItems = [:]
		for section in Section.allCases {
			self.sectionItems[section] = Self.extractItems(for: section)
		}
	}

	private static func extractItems(for section: Section) -> [(key: String, value: String)] {
		let rawItems: [[String: Any]]
		switch section {
		case .global:
			rawItems = SharedDelegate.shared.keychain.allItems()
		case .accounts:
			rawItems = AccountManager.shared.allRawItems()
		}
		return rawItems.compactMap { item in
			guard let key = item["key"] as? String else { return nil }
			let value = (item["value"] as? String) ?? ""
			return (key: key, value: value)
		}
	}
}

// MARK: - UITableViewDataSource
extension DebugSettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return 1 }
		return self.sectionItems[section]?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return nil }
		return section.title
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return nil }

		switch section {
		case .accounts:
			return "Values are JSON-encoded. Invalid edits will make accounts unreadable."
		case .global:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard let kDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: KDefaultsCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(KDefaultsCell.reuseID)")
		}
		guard let contentSection = self.contentSection(for: indexPath.section),
			  let section = Section(rawValue: contentSection) else { return kDefaultsCell }
		let items = self.sectionItems[section] ?? []
		let item = items[indexPath.row]

		kDefaultsCell.primaryLabel?.text = item.key
		kDefaultsCell.valueTextField.text = item.value
		kDefaultsCell.onValueChanged = { key, value in
			switch section {
			case .global:
				SharedDelegate.shared.keychain[key] = value
			case .accounts:
				AccountManager.shared.setRawValue(value, forKey: key)
			}
		}

		return kDefaultsCell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete,
			  let contentSection = self.contentSection(for: indexPath.section),
			  let section = Section(rawValue: contentSection) else { return }
		let items = self.sectionItems[section] ?? []
		let key = items[indexPath.row].key

		switch section {
		case .global:
			try? SharedDelegate.shared.keychain.remove(key)
		case .accounts:
			AccountManager.shared.removeRawValue(forKey: key)
		}

		self.sectionItems[section]?.remove(at: indexPath.row)
		self.tableView.deleteRows(at: [indexPath], with: .automatic)
		self.toggleEmptyDataView()
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let contentSection = self.contentSection(for: section) else { return .leastNormalMagnitude }
		return super.tableView(tableView, heightForHeaderInSection: contentSection)
	}
}

// MARK: - KTableViewDataSource
extension DebugSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			KDefaultsCell.self
		]
	}
}

// MARK: - Section
private enum Section: Int, CaseIterable {
	case global
	case accounts

	var title: String {
		switch self {
		case .global:
			return "Global"
		case .accounts:
			return "Accounts"
		}
	}
}
