//
//  DebugSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class DebugSettingsTableViewController: SubSettingsViewController {
	// MARK: - Views
	private var tableHeaderView: UIView!
	private var warningLabel: KLabel!

	// MARK: - Properties
	private var sectionItems: [Section: [(key: String, value: String)]] = [:]

	private var totalItemCount: Int {
		return self.sectionItems.values.reduce(0) { $0 + $1.count }
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.keysManager
		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.reloadSections()
		self.toggleEmptyDataView()
		self.configureView()
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		self.tableView.updateHeaderViewFrame()
	}

	// MARK: - Functions
	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.keychain)
		self.emptyBackgroundView.configureLabels(title: "No Keys", detail: "All keychain entries have been removed.")

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

	// Add text to table view header
	private func configureView() {
		self.configureTableHeaderView()
		self.configureWarningLabel()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureTableHeaderView() {
		self.tableHeaderView = UIView()
		self.tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
		self.tableHeaderView.backgroundColor = .clear
	}

	private func configureWarningLabel() {
		self.warningLabel = KLabel()
		self.warningLabel.translatesAutoresizingMaskIntoConstraints = false
		self.warningLabel.text = "Warning: Modifying these values may break your app! Proceed with caution."
		self.warningLabel.numberOfLines = 0
		self.warningLabel.textAlignment = .center
		self.warningLabel.font = .preferredFont(forTextStyle: .footnote)
	}

	private func configureViewHierarchy() {
		self.tableHeaderView.addSubview(self.warningLabel)
		self.tableView.tableHeaderView = self.tableHeaderView
	}

	private func configureViewConstraints() {
		guard let tableHeaderView = self.tableView.tableHeaderView else { return }

		NSLayoutConstraint.activate([
			self.tableHeaderView.leadingAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.leadingAnchor),
			self.tableHeaderView.trailingAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.trailingAnchor),
			self.tableHeaderView.topAnchor.constraint(equalTo: self.tableView.topAnchor),

			self.warningLabel.leadingAnchor.constraint(equalTo: tableHeaderView.layoutMarginsGuide.leadingAnchor, constant: 16),
			self.warningLabel.trailingAnchor.constraint(equalTo: tableHeaderView.layoutMarginsGuide.trailingAnchor, constant: -16),
			self.warningLabel.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 12),
			self.warningLabel.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor, constant: -24)
		])

		self.tableView.updateHeaderViewFrame()
	}
}

// MARK: - UITableViewDataSource
extension DebugSettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		return self.sectionItems[section]?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let section = Section(rawValue: section) else { return nil }
		return section.title
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let section = Section(rawValue: section) else { return nil }
		switch section {
		case .accounts:
			return "Values are JSON-encoded. Invalid edits will make accounts unreadable."
		case .global:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let kDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: KDefaultsCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(KDefaultsCell.reuseID)")
		}
		guard let section = Section(rawValue: indexPath.section) else { return kDefaultsCell }
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
		guard editingStyle == .delete, let section = Section(rawValue: indexPath.section) else { return }
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
}

// MARK: - KTableViewDataSource
extension DebugSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [KDefaultsCell.self]
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
