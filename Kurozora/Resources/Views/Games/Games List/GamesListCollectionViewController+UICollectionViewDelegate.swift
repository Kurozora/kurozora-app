//
//  GamesListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

extension GamesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard self.games[indexPath] != nil || self.relatedGames.indices.contains(indexPath.item) else { return }
		let segueIdentifier = R.segue.gamesListCollectionViewController.gameDetailsSegue
		self.performSegue(withIdentifier: segueIdentifier, sender: self.games[indexPath] ?? self.relatedGames[indexPath.item].game)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			let gameIdentitiesCount = self.relatedGames.count - 1
			var itemsCount = gameIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = gameIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchGames()
				}
			}
		default:
			let gameIdentitiesCount = self.gameIdentities.count - 1
			var itemsCount = gameIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = gameIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchGames()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			return self.relatedGames[safe: indexPath.item]?.game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default:
			guard self.games[indexPath] != nil else { return nil }
			return self.games[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
	}
}
