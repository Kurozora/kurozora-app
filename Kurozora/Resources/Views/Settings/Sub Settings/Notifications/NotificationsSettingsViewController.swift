//
//  NotificationsSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsSettingsViewController: SubSettingsViewController, StoryboardInstantiable {
	static var storyboardName: String = "NotificationSettings"

	// MARK: - IBOutlets
	@IBOutlet var allowNotificationsSwitch: KSwitch!
	@IBOutlet var soundsSwitch: KSwitch!
	@IBOutlet var badgeSwitch: KSwitch!

	// MARK: - Properties
	var numberOfSections = 3

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.allowNotificationsSwitch.isOn = UserSettings.notificationsAllowed
		self.soundsSwitch.isOn = UserSettings.notificationsSound
		self.badgeSwitch.isOn = UserSettings.notificationsBadge

		if !self.allowNotificationsSwitch.isOn {
			self.numberOfSections = 1
			self.tableView.reloadData()
		}
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: KSwitch) {
		guard let switchType = KNotification.Options(rawValue: sender.tag) else { return }
		let isOn = sender.isOn

		switch switchType {
		case .allowNotifications:
			UserSettings.set(isOn, forKey: .notificationsAllowed)
			if isOn {
				self.numberOfSections = 3
			} else {
				self.numberOfSections = 1
			}
			self.tableView.reloadData()
		case .sounds:
			UserSettings.set(isOn, forKey: .notificationsSound)
		case .badge:
			UserSettings.set(isOn, forKey: .notificationsBadge)
			NotificationCenter.default.post(name: .KSNotificationsBadgeIsOn, object: nil)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			let segueID = NotificationsTableViewController.SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		if let notificationsOptionsViewController = segue.destination as? NotificationsOptionsViewController {
			notificationsOptionsViewController.segueIdentifier = segueID
		}
	}
}

// MARK: - UITableViewDataSource
extension NotificationsSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.numberOfSections
	}
}
