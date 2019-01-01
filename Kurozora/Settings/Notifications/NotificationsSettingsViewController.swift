//
//  NotificationsSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsSettingsViewController: UITableViewController {
	@IBOutlet weak var collectionView: UICollectionView!

	@IBOutlet weak var allowNotificationsSwitch: UISwitch!
	@IBOutlet weak var soundsSwitch: UISwitch!
	@IBOutlet weak var vibrationsSwitch: UISwitch!
	@IBOutlet weak var badgeSwitch: UISwitch!
	@IBOutlet weak var notificationGroupingValueLabel: UILabel!
	@IBOutlet weak var bannerStyleValueLabel: UILabel!

	var onceOnly = true
	var numberOfSections = 4

	enum Alerts: Int {
		case basic = 0
		case icon
		case status
	}

	enum Switch: Int {
		case allowNotifications = 0
		case sounds
		case vibrations
		case badge
	}

	enum GroupingType: Int {
		case automatic = 0
		case byType
		case off
	}

	enum BannerStyle: Int {
		case temporary = 0
		case persistent
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let groupingType = GroupingType(rawValue: UserDefaults.standard.integer(forKey: "notificationsGrouping"))!
		let bannerStyle = BannerStyle(rawValue: UserDefaults.standard.integer(forKey: "notificationsPersistent"))!

		var groupingValue = "Automatic"
		var bannerStyleValue = "Temporary"

		switch groupingType {
		case .automatic: break
		case .byType:
			groupingValue = "By Type"
		case .off:
			groupingValue = "Off"
		}

		switch bannerStyle {
		case .temporary: break
		case .persistent:
			bannerStyleValue = "Persistent"
		}

		notificationGroupingValueLabel.text = groupingValue
		bannerStyleValueLabel.text = bannerStyleValue
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		allowNotificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsAllowed")
		soundsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsSound")
		vibrationsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsVibration")
		badgeSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsBadge")


		tableView.delegate = self
		tableView.dataSource = self

		collectionView.dataSource = self
		collectionView.delegate = self

		if !allowNotificationsSwitch.isOn {
			numberOfSections = 1
			tableView.reloadData()
		}
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: UISwitch) {
		let switchType = Switch(rawValue: sender.tag)!
		let isOn = sender.isOn

		switch switchType {
		case .allowNotifications:
			UserDefaults.standard.set(isOn, forKey: "notificationsAllowed")
			if isOn {
				numberOfSections = 4
			} else {
				numberOfSections = 1
			}
			tableView.reloadData()
		case .sounds:
				UserDefaults.standard.set(isOn, forKey: "notificationsSound")
		case .vibrations:
				UserDefaults.standard.set(isOn, forKey: "notificationsVibration")
		case .badge:
				UserDefaults.standard.set(isOn, forKey: "notificationsBadge")
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? NotificationsOptionsViewController {
			vc.segueIdentifier = segue.identifier
		}
	}
}

extension NotificationsSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return numberOfSections
	}
}

extension NotificationsSettingsViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let notificationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! SettingsNotificationCell
		let alertsType = Alerts(rawValue: indexPath.row)!
		let selected = UserDefaults.standard.integer(forKey: "alertType")

		switch alertsType {
		case .basic:
			notificationCell.previewImageView.image = #imageLiteral(resourceName: "session_icon")
			notificationCell.titleLabel.text = "Basic"
		case .icon:
			notificationCell.previewImageView.image = #imageLiteral(resourceName: "restore_icon")
			notificationCell.titleLabel.text = "Icon"
		case .status:
			notificationCell.previewImageView.image = #imageLiteral(resourceName: "notifications_icon")
			notificationCell.titleLabel.text = "Status Bar"
		}

		if alertsType.rawValue == selected {
			notificationCell.isSelected = true
		}

		return notificationCell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		UserDefaults.standard.set(indexPath.row, forKey: "alertType")
		collectionView.reloadData()
	}
}

extension NotificationsSettingsViewController: UICollectionViewDelegate {
}
