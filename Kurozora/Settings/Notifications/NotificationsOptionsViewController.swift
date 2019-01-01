//
//  NotificationsOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsOptionsViewController: UICollectionViewController {
	var segueType: SegueType!
	public var segueIdentifier: String!

	enum SegueType: String {
		case notificationsGrouping = "notificationsGroupingSegue"
		case bannerStyle = "bannerStyleSegue"
	}

	enum NotificationGrouping: Int {
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
		segueType = SegueType(rawValue: segueIdentifier)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
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
			let grouping = NotificationGrouping(rawValue: indexPath.item)!
			let selected = UserDefaults.standard.integer(forKey: "notificationsGrouping")

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
			let bannerStyle = BannerStyle(rawValue: indexPath.item)!
			let selected = UserDefaults.standard.integer(forKey: "notificationsPersistent")

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
			UserDefaults.standard.set(indexPath.item, forKey: "notificationsGrouping")
		case .bannerStyle:
			UserDefaults.standard.set(indexPath.item, forKey: "notificationsPersistent")
		}

		collectionView.reloadData()
	}
}
