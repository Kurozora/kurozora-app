//
//  ShowListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ShowsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let show = self.cache[indexPath] as? Show
		let relatedShow = self.relatedShows[safe: indexPath.item]?.show
		guard let show = show ?? relatedShow else { return }
		let segueIdentifier = R.segue.showsListCollectionViewController.showDetailsSegue
		self.performSegue(withIdentifier: segueIdentifier, sender: show)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			let showIdentitiesCount = self.relatedShows.count - 1
			var itemsCount = showIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = showIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount, self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchShows()
				}
			}
		default:
			let showIdentitiesCount = self.showIdentities.count - 1
			var itemsCount = showIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = showIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount, self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchShows()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let show = self.cache[indexPath] as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}
