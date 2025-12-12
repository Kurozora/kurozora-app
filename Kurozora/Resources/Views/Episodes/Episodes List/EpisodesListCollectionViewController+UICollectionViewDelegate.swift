//
//  EpisodesListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension EpisodesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let episode = self.cache[indexPath] as? Episode else { return }
		self.performSegue(withIdentifier: SegueIdentifiers.episodeDetailsSegue, sender: [indexPath: episode])
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let episodeIdentitiesCount = self.episodeIdentities.count - 1
		var itemsCount = episodeIdentitiesCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = episodeIdentitiesCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount, self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchEpisodes()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let episode = self.cache[indexPath] as? Episode else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		return episode.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
