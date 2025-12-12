//
//  ReCapCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReCapCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .topShows(let recapItem), .topGames(let recapItem), .topLiteratures(let recapItem):
			switch recapItem.attributes.recapItemType {
			case .shows:
				guard let show = self.cache[indexPath] as? Show else { return }
				self.performSegue(withIdentifier: SegueIdentifiers.showDetailsSegue, sender: show)
			case .literatures:
				guard let literature = self.cache[indexPath] as? Literature else { return }
				self.performSegue(withIdentifier: SegueIdentifiers.literatureDetailsSegue, sender: literature)
			case .games:
				guard let game = self.cache[indexPath] as? Game else { return }
				self.performSegue(withIdentifier: SegueIdentifiers.gameDetailsSegue, sender: game)
			case .genres:
				guard let genre = self.cache[indexPath] as? Genre else { return }
				self.performSegue(withIdentifier: SegueIdentifiers.genresSegue, sender: genre)
			case .themes:
				guard let theme = self.cache[indexPath] as? Theme else { return }
				self.performSegue(withIdentifier: SegueIdentifiers.themesSegue, sender: theme)
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
				guard let shows = self.cache[indexPath] as? Show else { return nil }
				return shows.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .literatures:
				guard let literatures = self.cache[indexPath] as? Literature else { return nil }
				return literatures.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .games:
				guard let games = self.cache[indexPath] as? Game else { return nil }
				return games.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .genres:
				guard let genres = self.cache[indexPath] as? Genre else { return nil }
				return genres.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			case .themes:
				guard let themes = self.cache[indexPath] as? Theme else { return nil }
				return themes.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			}
		}
		return nil
	}
}
