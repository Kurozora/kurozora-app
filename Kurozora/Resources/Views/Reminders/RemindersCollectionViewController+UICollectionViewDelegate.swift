//
//  RemindersCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

extension RemindersCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.libraryKind {
		case .shows:
			guard let show = self.shows[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: R.segue.remindersCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			guard let literature = self.literatures[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: R.segue.remindersCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			guard let game = self.games[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: R.segue.remindersCollectionViewController.gameDetailsSegue, sender: game)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.libraryKind {
		case .shows:
			if indexPath.item == self.shows.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchRemindersList()
				}
			}
		case .literatures:
			if indexPath.item == self.literatures.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchRemindersList()
				}
			}
		case .games:
			if indexPath.item == self.games.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchRemindersList()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.libraryKind {
		case .shows:
			return self.shows[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatures:
			return self.literatures[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .games:
			return self.games[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
	}
}
