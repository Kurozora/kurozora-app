//
//  NotificationsSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsSettingsViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var allowNotificationsSwitch: KSwitch!
	@IBOutlet weak var soundsSwitch: KSwitch!
	@IBOutlet weak var vibrationsSwitch: KSwitch!
	@IBOutlet weak var badgeSwitch: KSwitch!

	// MARK: - Properties
	var numberOfSections = 4

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		allowNotificationsSwitch.isOn = UserSettings.notificationsAllowed
		soundsSwitch.isOn = UserSettings.notificationsSound
		vibrationsSwitch.isOn = UserSettings.notificationsVibration
		badgeSwitch.isOn = UserSettings.notificationsBadge

		if !allowNotificationsSwitch.isOn {
			numberOfSections = 1
			tableView.reloadData()
		}
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: KSwitch) {
		let switchType = KNotification.Options(rawValue: sender.tag)!
		let isOn = sender.isOn

		switch switchType {
		case .allowNotifications:
			UserSettings.set(isOn, forKey: .notificationsAllowed)
			if isOn {
				numberOfSections = 4
			} else {
				numberOfSections = 1
			}
			tableView.reloadData()
		case .sounds:
			UserSettings.set(isOn, forKey: .notificationsSound)
		case .vibrations:
			UserSettings.set(isOn, forKey: .notificationsVibration)
		case .badge:
			UserSettings.set(isOn, forKey: .notificationsBadge)
			NotificationCenter.default.post(name: .KSNotificationsBadgeIsOn, object: nil)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let notificationsOptionsViewController = segue.destination as? NotificationsOptionsViewController {
			notificationsOptionsViewController.segueIdentifier = segue.identifier
		}
	}
}

// MARK: - UITableViewDataSource
extension NotificationsSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return numberOfSections
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let notificationSettingsCell = super.tableView(tableView, cellForRowAt: indexPath) as? NotificationSettingsCell {
			notificationSettingsCell.updateAlertType(with: UserSettings.alertType)
			return notificationSettingsCell
		}

		return super.tableView(tableView, cellForRowAt: indexPath)
	}
}
