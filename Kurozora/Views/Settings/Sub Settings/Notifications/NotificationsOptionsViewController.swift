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
	var segueIdentifier: String?

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let notificationSegueIdentifier = KNotification.Settings(stringValue: segueIdentifier)
		self.notificationSegueIdentifier = notificationSegueIdentifier
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			title = "Notification Grouping"
		}
	}
}

// MARK: - UITableViewDataSource
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			return 3
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let notificationsGroupingCell = tableView.dequeueReusableCell(withIdentifier: "SelectableSettingsCell", for: indexPath) as! SelectableSettingsCell
		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			let grouping = KNotification.GroupStyle(rawValue: indexPath.item)!
			let selected = UserSettings.notificationsGrouping

			switch grouping {
			case .automatic:
				notificationsGroupingCell.primaryLabel?.text = "Automatic"
			case .byType:
				notificationsGroupingCell.primaryLabel?.text = "By Type"
			case .off:
				notificationsGroupingCell.primaryLabel?.text = "Off"
			}

			if grouping.rawValue == selected {
				notificationsGroupingCell.isSelected = true
			}
		}

		return notificationsGroupingCell
	}
}

// MARK: - UITableViewDelegate
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			UserSettings.set(indexPath.item, forKey: .notificationsGrouping)
		}

		NotificationCenter.default.post(name: .KSNotificationOptionsValueLabelsNotification, object: nil)
		tableView.reloadData()
	}
}
