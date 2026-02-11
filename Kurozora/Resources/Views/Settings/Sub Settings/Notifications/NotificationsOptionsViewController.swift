//
//  NotificationsOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsOptionsViewController: SubSettingsViewController {
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

		self.title = Trans.notificationGrouping

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - UITableViewDataSource
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return KNotification.GroupStyle.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectableSettingsCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(SelectableSettingsCell.reuseID).")
		}
		let notificationGrouping = KNotification.GroupStyle(rawValue: indexPath.row) ?? .automatic
		let selectedNotificationGrouping = UserSettings.notificationsGrouping

		cell.configure(title: notificationGrouping.stringValue)
		cell.setSelected(notificationGrouping.rawValue == selectedNotificationGrouping)
		return cell
	}
}

// MARK: - UITableViewDelegate
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UserSettings.set(indexPath.row, forKey: .notificationsGrouping)

		NotificationCenter.default.post(name: .KSNotificationOptionsValueLabelsNotification, object: nil)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension NotificationsOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SelectableSettingsCell.self]
	}
}
