//
//  NotificationsSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsSettingsViewController: SubSettingsViewController {
	// MARK: - Segue Identifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case notificationsGroupingSegue
	}

	// MARK: - Properties
	private var allowsNotifications = UserSettings.notificationsAllowed

	private var visibleSections: [Section] {
		return self.allowsNotifications ? [.allowNotifications, .preferences, .grouping] : [.allowNotifications]
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotificationValueLabels), name: .KSNotificationOptionsValueLabelsNotification, object: nil)

		self.title = Trans.notifications

		self.configureView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let currentAllowsNotifications = UserSettings.notificationsAllowed

		if currentAllowsNotifications != self.allowsNotifications {
			self.allowsNotifications = currentAllowsNotifications
			self.tableView.reloadData()
		}
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	@objc private func updateNotificationValueLabels() {
		self.tableView.reloadData()
	}

	private func configureSwitchCell(_ cell: SwitchSettingsCell, title: String, isOn: Bool, tag: KNotification.Options) {
		cell.configure(title: title, isOn: isOn, tag: tag.rawValue, action: UIAction { [weak self] action in
			guard
				let self = self,
				let sender = action.sender as? KSwitch
			else { return }
			self.switchTapped(sender)
		})
	}

	// MARK: - Actions
	@objc private func switchTapped(_ sender: KSwitch) {
		guard let switchType = KNotification.Options(rawValue: sender.tag) else { return }
		let isOn = sender.isOn

		switch switchType {
		case .allowNotifications:
			UserSettings.set(isOn, forKey: .notificationsAllowed)
			self.allowsNotifications = isOn
			self.tableView.reloadData()
		case .sounds:
			UserSettings.set(isOn, forKey: .notificationsSound)
		case .badge:
			UserSettings.set(isOn, forKey: .notificationsBadge)
			NotificationCenter.default.post(name: .KSNotificationsBadgeIsOn, object: nil)
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .notificationsGroupingSegue:
			return NotificationsOptionsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .notificationsGroupingSegue:
			if let notificationsOptionsViewController = destination as? NotificationsOptionsViewController {
				notificationsOptionsViewController.segueIdentifier = identifier
			}
		}
	}
}

// MARK: - KTableViewDataSource
extension NotificationsSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension NotificationsSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.visibleSections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.visibleSections[section] {
		case .allowNotifications:
			return 1
		case .preferences:
			return PreferencesRow.allCases.count
		case .grouping:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.visibleSections[indexPath.section] {
		case .allowNotifications:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: Trans.allowNotifications, isOn: UserSettings.notificationsAllowed, tag: .allowNotifications)
			return cell
		case .preferences:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}

			let row = PreferencesRow(rawValue: indexPath.row) ?? .sounds
			switch row {
			case .sounds:
				self.configureSwitchCell(cell, title: Trans.sounds, isOn: UserSettings.notificationsSound, tag: .sounds)
			case .badges:
				self.configureSwitchCell(cell, title: Trans.badges, isOn: UserSettings.notificationsBadge, tag: .badge)
			}

			return cell
		case .grouping:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			let notificationGroupingValue = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping)

			cell.configure(using: Trans.notificationGrouping, secondaryTitle: notificationGroupingValue?.stringValue)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch self.visibleSections[section] {
		case .allowNotifications:
			return "Receive notifications inside Kurozora while using the app. This is separate from systemwide notifications for Kurozora."
		case .preferences, .grouping:
			return nil
		}
	}
}

// MARK: - UITableViewDelegate
extension NotificationsSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch self.visibleSections[indexPath.section] {
		case .grouping:
			let optionsViewController = NotificationsOptionsViewController()
			optionsViewController.segueIdentifier = .notificationsGroupingSegue
			self.show(optionsViewController, sender: nil)
		case .allowNotifications, .preferences:
			break
		}
	}
}

// MARK: - Sections and Rows
extension NotificationsSettingsViewController {
	/// List of notification settings sections.
	enum Section: Int, CaseIterable {
		case allowNotifications = 0
		case preferences
		case grouping
	}

	/// List of notification settings preferences rows.
	private enum PreferencesRow: Int, CaseIterable {
		case sounds
		case badges
	}
}
