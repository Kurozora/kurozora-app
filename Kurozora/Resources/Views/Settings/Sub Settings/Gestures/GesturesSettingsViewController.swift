//
//  GesturesSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class GesturesSettingsViewController: SubSettingsViewController {
	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.handPointUp
		self.headerTitle = L10n.gestures
		self.headerDescription = L10n.gesturesHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFooters), name: .GCKeyboardDidConnect, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFooters), name: .GCKeyboardDidDisconnect, object: nil)

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	// MARK: - Functions
	private func configureSwitchCell(_ cell: SwitchSettingsCell, title: String, isOn: Bool, tag: Gestures.Row) {
		cell.configure(title: title, isOn: isOn, tag: tag.rawValue, action: UIAction { [weak self] action in
			guard
				let self = self,
				let sender = action.sender as? KSwitch
			else { return }
			self.switchTapped(sender)
		})
	}

	// MARK: - Actions
	@objc private func reloadFooters() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	@objc private func switchTapped(_ sender: KSwitch) {
		guard let switchType = Gestures.Row(rawValue: sender.tag) else { return }

		switch switchType {
		case .toggleForwardNavigation:
			UserSettings.set(sender.isOn, forKey: .forwardNavigationEnabled)
			NotificationCenter.default.post(name: .KSForwardNavigationDidChange, object: nil)
		}
	}
}

// MARK: - KTableViewDataSource
extension GesturesSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SwitchSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension GesturesSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Gestures.Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section) else { return 1 }
		return Gestures.Section.allCases[contentSection].rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard let contentSection = self.contentSection(for: indexPath.section) else { return UITableViewCell() }
		let section = Gestures.Section.allCases[contentSection]

		switch section {
		case .navigation:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			let row = section.rows[indexPath.row]

			switch row {
			case .toggleForwardNavigation:
				self.configureSwitchCell(cell, title: row.titleValue, isOn: UserSettings.forwardNavigationEnabled, tag: .toggleForwardNavigation)
			}

			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = Gestures.Section(rawValue: contentSection)
		else { return nil }

		return section.titleValue
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = Gestures.Section(rawValue: contentSection)
		else { return nil }

		return section.footerValue
	}
}
