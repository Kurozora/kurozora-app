//
//  PortraitLockSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class PortraitLockSettingsViewController: SubSettingsViewController {
	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.lock
		self.headerTitle = L10n.portraitLock
		self.headerDescription = L10n.portraitLockHeaderDescription
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

	// MARK: - Functions
	private func configureSwitchCell(_ cell: SwitchSettingsCell, row: Row, isOn: Bool) {
		cell.configure(title: row.titleValue, isOn: isOn, tag: row.rawValue, action: UIAction { [weak self] action in
			guard
				let self = self,
				let toggle = action.sender as? KSwitch
			else { return }

			self.switchTapped(toggle)
		})
	}

	// MARK: - Actions
	@objc private func switchTapped(_ sender: KSwitch) {
		guard let row = Row(rawValue: sender.tag) else { return }

		switch row {
		case .smartRotationLock:
			UserSettings.set(sender.isOn, forKey: .isSmartRotationLockEnabled)

			if #available(iOS 16.0, *) {
				self.setNeedsUpdateOfSupportedInterfaceOrientations()
			}
		case .portraitLockBuddy:
			UserSettings.set(sender.isOn, forKey: .isPortraitLockBuddyEnabled)
		}
	}
}

// MARK: - KTableViewDataSource
extension PortraitLockSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SwitchSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension PortraitLockSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Row.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let row = Row(rawValue: contentSection),
			let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath)
		else {
			return UITableViewCell()
		}

		self.configureSwitchCell(cell, row: row, isOn: row.isOn)
		return cell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let row = Row(rawValue: contentSection)
		else { return nil }

		return row.footerValue
	}
}

// MARK: - Rows
private extension PortraitLockSettingsViewController {
	enum Row: Int, CaseIterable {
		case smartRotationLock
		case portraitLockBuddy

		var titleValue: String {
			switch self {
			case .smartRotationLock:
				return L10n.smartRotationLock
			case .portraitLockBuddy:
				return L10n.portraitLockBuddy
			}
		}

		var footerValue: String {
			switch self {
			case .smartRotationLock:
				return L10n.smartRotationLockFooter
			case .portraitLockBuddy:
				return L10n.portraitLockBuddyFooter
			}
		}

		var isOn: Bool {
			switch self {
			case .smartRotationLock:
				return UserSettings.isSmartRotationLockEnabled
			case .portraitLockBuddy:
				return UserSettings.isPortraitLockBuddyEnabled
			}
		}
	}
}
