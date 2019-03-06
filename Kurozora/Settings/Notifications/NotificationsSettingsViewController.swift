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
		allowNotificationsSwitch.theme_tintColor = "Global.tintColor"
		soundsSwitch.theme_tintColor = "Global.tintColor"
		vibrationsSwitch.theme_tintColor = "Global.tintColor"
		badgeSwitch.theme_tintColor = "Global.tintColor"

		let groupingType = GroupingType(rawValue: UserSettings.notificationsGrouping())!
		let bannerStyle = BannerStyle(rawValue: UserSettings.notificationsPersistent())!

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
		view.theme_backgroundColor = "Global.backgroundColor"
		
		allowNotificationsSwitch.isOn = UserSettings.notificationsAllowed()
		soundsSwitch.isOn = UserSettings.notificationsSound()
		vibrationsSwitch.isOn = UserSettings.notificationsVibration()
		badgeSwitch.isOn = UserSettings.notificationsBadge()


		tableView.delegate = self
		tableView.dataSource = self

		collectionView.dataSource = self
		collectionView.delegate = self

		if !allowNotificationsSwitch.isOn {
			numberOfSections = 1
			tableView.reloadData()
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		for cell in tableView.visibleCells {
			guard let indexPath = tableView.indexPath(for: cell) else { return }
			var rectCorner: UIRectCorner!
			var roundCorners = true
			let numberOfRows: Int = tableView.numberOfRows(inSection: indexPath.section)

			if numberOfRows == 1 {
				// single cell
				rectCorner = UIRectCorner.allCorners
			} else if indexPath.row == numberOfRows - 1 {
				// bottom cell
				rectCorner = [.bottomLeft, .bottomRight]
			} else if indexPath.row == 0 {
				// top cell
				rectCorner = [.topLeft, .topRight]
			} else {
				roundCorners = false
			}

			if roundCorners {
				tableView.cellForRow(at: indexPath)?.contentView.roundedCorners(rectCorner, radius: 10)
			}
		}
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: UISwitch) {
		let switchType = Switch(rawValue: sender.tag)!
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
}

// MARK: - UITableViewDelegate
extension NotificationsSettingsViewController {
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.theme_textColor = "Global.textColor"
			headerView.textLabel?.alpha = 0.50
		}
	}
}

// MARK: - UICollectionViewDataSource
extension NotificationsSettingsViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let notificationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! SettingsNotificationCell
		let alertsType = Alerts(rawValue: indexPath.row)!
		let selected = UserSettings.alertType()

		switch alertsType {
		case .basic:
			if UIDevice.isPad() {
				notificationCell.previewImageView.image = #imageLiteral(resourceName: "notification_basic_ipad")
			} else {
				notificationCell.previewImageView.image = #imageLiteral(resourceName: "notification_basic_iphone")
			}
			notificationCell.titleLabel.text = "Basic"
		case .icon:
			if UIDevice.isPad() {
				notificationCell.previewImageView.image = #imageLiteral(resourceName: "notification_icon_ipad")
			} else {
				notificationCell.previewImageView.image = #imageLiteral(resourceName: "notification_icon_iphone")
			}
			notificationCell.titleLabel.text = "Icon"
		case .status:
			if UIDevice.isPad() {
				notificationCell.previewImageView.image = #imageLiteral(resourceName: "notification_statusbar_ipad")
			} else {
				notificationCell.previewImageView.image = #imageLiteral(resourceName: "notification_statusbar_iphone")
			}
			notificationCell.titleLabel.text = "Status Bar"
		}

		if alertsType.rawValue == selected {
			notificationCell.isSelected = true
		}

		return notificationCell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		UserSettings.set(indexPath.row, forKey: .alertType)
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDelegate
extension NotificationsSettingsViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegate
extension NotificationsSettingsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}
}
