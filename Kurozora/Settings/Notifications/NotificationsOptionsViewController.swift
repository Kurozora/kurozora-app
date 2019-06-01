//
//  NotificationsOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsOptionsViewController: UICollectionViewController {
	var segueType: NotificationSegueIdentifier!
	public var segueIdentifier: String!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		segueType = NotificationSegueIdentifier(rawValue: segueIdentifier)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let segueType = segueType else { return 0 }

		switch segueType {
		case .notificationsGrouping:
			return 3
		case .bannerStyle:
			return 2
		}
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let notificationsGroupingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationsGroupingCell", for: indexPath) as! NotificationsGroupingCell
		guard let segueType = segueType else { return notificationsGroupingCell }

		switch segueType {
		case .notificationsGrouping:
			let grouping = NotificationGroupStyle(rawValue: indexPath.item)!
			let selected = UserSettings.notificationsGrouping()

			switch grouping {
			case .automatic:
				notificationsGroupingCell.titleLabel.text = "Automatic"
			case .byType:
				notificationsGroupingCell.titleLabel.text = "By Type"
			case .off:
				notificationsGroupingCell.titleLabel.text = "Off"
			}

			if grouping.rawValue == selected {
				notificationsGroupingCell.isSelected = true
			}
		case .bannerStyle:
			let bannerStyle = NotificationBannerStyle(rawValue: indexPath.item)!
			let selected = UserSettings.notificationsPersistent()

			switch bannerStyle {
			case .temporary:
				notificationsGroupingCell.titleLabel.text = "Temporary"
			case .persistent:
				notificationsGroupingCell.titleLabel.text = "Persistent"
			}

			if bannerStyle.rawValue == selected {
				notificationsGroupingCell.isSelected = true
			}
		}

		return notificationsGroupingCell
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let segueType = segueType else { return }

		switch segueType {
		case .notificationsGrouping:
			UserSettings.set(indexPath.item, forKey: .notificationsGrouping)
		case .bannerStyle:
			UserSettings.set(indexPath.item, forKey: .notificationsPersistent)
		}

		collectionView.reloadData()
	}
}
