//
//  NotificationsSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationsSettingsViewController: UITableViewController {
	@IBOutlet weak var allowNotificationsSwitch: UISwitch! {
		didSet {
			allowNotificationsSwitch.theme_onTintColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var soundsSwitch: UISwitch! {
		didSet {
			soundsSwitch.theme_onTintColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var vibrationsSwitch: UISwitch! {
		didSet {
			vibrationsSwitch.theme_onTintColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var badgeSwitch: UISwitch! {
		didSet {
			badgeSwitch.theme_onTintColor = KThemePicker.tintColor.rawValue
		}
	}

	var numberOfSections = 4

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		
		allowNotificationsSwitch.isOn = UserSettings.notificationsAllowed
		soundsSwitch.isOn = UserSettings.notificationsSound
		vibrationsSwitch.isOn = UserSettings.notificationsVibration
		badgeSwitch.isOn = UserSettings.notificationsBadge

		tableView.delegate = self
		tableView.dataSource = self

		if !allowNotificationsSwitch.isOn {
			numberOfSections = 1
			tableView.reloadData()
		}
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: UISwitch) {
		let switchType = NotificationOptions(rawValue: sender.tag)!
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
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? NotificationsOptionsViewController {
			vc.segueIdentifier = segue.identifier
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

// MARK: - UITableViewDelegate
extension NotificationsSettingsViewController {
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
			headerView.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell
		if settingsCell?.selectedView != nil {
			settingsCell?.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			settingsCell?.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

			settingsCell?.cellTitle?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			settingsCell?.bannerStyleValueLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			settingsCell?.notificationGroupingValueLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell
		if settingsCell?.selectedView != nil {
			settingsCell?.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			settingsCell?.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			settingsCell?.cellTitle?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell?.bannerStyleValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			settingsCell?.notificationGroupingValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
}
