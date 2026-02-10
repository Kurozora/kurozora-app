//
//  NotificationsOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsOptionsViewController: SubSettingsViewController {
	// MARK: - Properties
	var notificationSegueIdentifier: KNotification.Settings = .notificationsGrouping
	var segueIdentifier: NotificationsSettingsViewController.SegueIdentifiers?

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

		switch self.notificationSegueIdentifier {
		case .notificationsGrouping:
			self.title = Trans.notificationGrouping
		}

		self.configureView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		guard let segueIdentifier = self.segueIdentifier else { return }
		let notificationSegueIdentifier = KNotification.Settings(segueIdentifier: segueIdentifier)
		self.notificationSegueIdentifier = notificationSegueIdentifier
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - UITableViewDataSource
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.notificationSegueIdentifier {
		case .notificationsGrouping:
			return 3
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let notificationsGroupingCell = tableView.dequeueReusableCell(withIdentifier: "SelectableSettingsCell", for: indexPath) as? SelectableSettingsCell else {
			fatalError("Cannot dequeue reusable cell with identifier SelectableSettingsCell.")
		}

		switch self.notificationSegueIdentifier {
		case .notificationsGrouping:
			let notificationGrouping = KNotification.GroupStyle(rawValue: indexPath.item) ?? .automatic
			let selectedNotificationGrouping = UserSettings.notificationsGrouping

			notificationsGroupingCell.primaryLabel?.text = notificationGrouping.stringValue
			notificationsGroupingCell.setSelected(notificationGrouping.rawValue == selectedNotificationGrouping)
		}

		return notificationsGroupingCell
	}
}

// MARK: - UITableViewDelegate
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch self.notificationSegueIdentifier {
		case .notificationsGrouping:
			UserSettings.set(indexPath.item, forKey: .notificationsGrouping)
		}

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
