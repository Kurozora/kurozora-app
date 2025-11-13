//
//  ReCapCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ReCapCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .topShows(let recapItem), .topGames(let recapItem), .topLiteratures(let recapItem):
			switch recapItem.attributes.recapItemType {
			case .shows:
				guard let show = self.shows[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.reCapCollectionViewController.showDetailsSegue, sender: show)
			case .literatures:
				guard let literature = self.literatures[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.reCapCollectionViewController.literatureDetailsSegue, sender: literature)
			case .games:
				guard let game = self.games[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.reCapCollectionViewController.gameDetailsSegue, sender: game)
			case .genres:
				guard let genre = self.genres[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.reCapCollectionViewController.genresSegue, sender: genre)
			case .themes:
				guard let theme = self.themes[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.reCapCollectionViewController.themesSegue, sender: theme)
			}
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		if indexPath.section <= self.recapItems.count {
			let recapItem = self.recapItems[indexPath.section]

			switch recapItem.attributes.recapItemType {
			case .shows:
				return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .literatures:
				return self.literatures[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .games:
				return self.games[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .genres:
				return self.genres[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .themes:
				return self.themes[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			}
		}
		return nil
	}
}
