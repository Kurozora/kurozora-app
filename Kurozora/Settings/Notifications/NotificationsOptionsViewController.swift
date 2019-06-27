//
//  NotificationsOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsOptionsViewController: UITableViewController {
	var notificationSegueIdentifier: NotificationSegueIdentifier = .bannerStyle
	var segueIdentifier: String!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let notificationSegueIdentifier = NotificationSegueIdentifier(rawValue: segueIdentifier) {
			self.notificationSegueIdentifier = notificationSegueIdentifier
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			title = "Notification Grouping"
		case .bannerStyle:
			title = "Banner Style"
		}
	}
}

// MARK: - UITableViewDataSource
extension NotificationsOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			return 3
		case .bannerStyle:
			return 2
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let notificationsGroupingCell = tableView.dequeueReusableCell(withIdentifier: "SelectableSettingsCell", for: indexPath) as! SelectableSettingsCell
		switch notificationSegueIdentifier {
		case .notificationsGrouping:
			let grouping = NotificationGroupStyle(rawValue: indexPath.item)!
			let selected = UserSettings.notificationsGrouping

			switch grouping {
			case .automatic:
				notificationsGroupingCell.cellTitle?.text = "Automatic"
			case .byType:
				notificationsGroupingCell.cellTitle?.text = "By Type"
			case .off:
				notificationsGroupingCell.cellTitle?.text = "Off"
			}

			if grouping.rawValue == selected {
				notificationsGroupingCell.isSelected = true
			}
		case .bannerStyle:
			let bannerStyle = NotificationBannerStyle(rawValue: indexPath.item)!
			let selected = UserSettings.notificationsPersistent

			switch bannerStyle {
			case .temporary:
				notificationsGroupingCell.cellTitle?.text = "Temporary"
			case .persistent:
				notificationsGroupingCell.cellTitle?.text = "Persistent"
			}

			if bannerStyle.rawValue == selected {
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
		case .bannerStyle:
			UserSettings.set(indexPath.item, forKey: .notificationsPersistent)
		}

		NotificationCenter.default.post(name: updateNotificationSettingsValueLabelsNotification, object: nil)
		tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let notificationsGroupingCell = tableView.cellForRow(at: indexPath) as? SelectableSettingsCell {
			notificationsGroupingCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			notificationsGroupingCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let notificationsGroupingCell = tableView.cellForRow(at: indexPath) as? SelectableSettingsCell {
			notificationsGroupingCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			notificationsGroupingCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
}
