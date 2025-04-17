//
//  ScheduleCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ScheduleCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .schedule(let schedule):
			if let shows = schedule.relationships.shows?.data {
				guard let show = shows[safe: indexPath.item] else { return }
				self.performSegue(withIdentifier: R.segue.scheduleCollectionViewController.showDetailsSegue, sender: show)
			} else if let literatures = schedule.relationships.literatures?.data {
				guard let literature = literatures[safe: indexPath.item] else { return }
				self.performSegue(withIdentifier: R.segue.scheduleCollectionViewController.literatureDetailsSegue, sender: literature)
			} else if let games = schedule.relationships.games?.data {
				guard let game = games[safe: indexPath.item] else { return }
				self.performSegue(withIdentifier: R.segue.scheduleCollectionViewController.gameDetailsSegue, sender: game)
			}
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section <= self.schedules.count {
			let schedule = self.schedules[indexPath.section]

			if let shows = schedule.relationships.shows?.data {
				return shows[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			} else if let literatures = schedule.relationships.literatures?.data {
				return literatures[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			} else if let games = schedule.relationships.games?.data {
				return games[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		}
		return nil
	}
}
