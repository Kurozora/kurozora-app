//
//  RemindersSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class RemindersSettingsViewController: SubSettingsViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reminderSubscriptionSegue
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.bell
		self.headerTitle = L10n.reminders
		self.headerDescription = L10n.remindersHeaderDescription
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.tableView.reloadData()
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reminderSubscriptionSegue:
			return ReminderSubscriptionTableViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) { }

	// MARK: - Functions
	private func configureSwitchCell(_ cell: SwitchSettingsCell, row: Row) {
		cell.configure(title: row.title, isOn: UserSettings.airingRemindersAllowed, tag: row.rawValue, action: UIAction { [weak self] action in
			guard let self = self else { return }
			guard let sender = action.sender as? KSwitch else { return }

			UserSettings.set(sender.isOn, forKey: .airingRemindersAllowed)
			self.tableView.reloadData()

			Task {
				await AiringNotificationScheduler.shared.refresh()
			}
		})
	}
}

// MARK: - KTableViewDataSource
extension RemindersSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SettingsCell.self,
			SwitchSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension RemindersSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return 1 }
		return section.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = Section(rawValue: contentSection),
			let row = section.rows[safe: indexPath.row]
		else {
			return UITableViewCell()
		}

		switch row {
		case .releaseReminders:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			self.configureSwitchCell(cell, row: row)
			return cell
		case .testReminder, .subscription:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			let isEnabled = row == .subscription || UserSettings.airingRemindersAllowed

			cell.configure(title: row.title, isEnabled: isEnabled)
			cell.chevronImageView?.isHidden = row == .testReminder
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return nil }
		return section.footer
	}
}

// MARK: - UITableViewDelegate
extension RemindersSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = Section(rawValue: contentSection),
			let row = section.rows[safe: indexPath.row]
		else { return }

		switch row {
		case .releaseReminders:
			return
		case .subscription:
			Task { [weak self] in
				guard let self = self else { return }
				guard await WorkflowController.shared.isSubscribed(on: self) else { return }

				self.show(SegueIdentifiers.reminderSubscriptionSegue, sender: nil)
			}
		case .testReminder:
			#if DEBUG
			Task {
				await AiringNotificationScheduler.shared.fireTestReminder()
			}
			#endif
		}
	}
}

// MARK: - Sections and Rows
private extension RemindersSettingsViewController {
	enum Section: Int, CaseIterable {
		case onDevice = 0
		case subscription = 1

		var rows: [Row] {
			switch self {
			case .onDevice:
				#if DEBUG
				return [.releaseReminders, .testReminder]
				#else
				return [.releaseReminders]
				#endif
			case .subscription:
				return [.subscription]
			}
		}

		var footer: String? {
			switch self {
			case .onDevice:
				return L10n.airingRemindersFooter
			case .subscription:
				return L10n.reminderSubscriptionRowFooter
			}
		}
	}

	enum Row: Int {
		case releaseReminders = 0
		case testReminder
		case subscription

		var title: String {
			switch self {
			case .releaseReminders:
				return L10n.airingReminders
			case .testReminder:
				return "Send Test Reminder"
			case .subscription:
				return L10n.subscribeToReminders
			}
		}
	}
}
