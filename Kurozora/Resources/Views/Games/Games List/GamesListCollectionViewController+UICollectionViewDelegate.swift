//
//  GamesListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension GamesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let game = self.cache[indexPath] as? Game
		let relatedGame = self.relatedGames[safe: indexPath.item]?.game
		guard let game = game ?? relatedGame else { return }
		self.performSegue(withIdentifier: SegueIdentifiers.gameDetailsSegue, sender: game)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			let gameIdentitiesCount = self.relatedGames.count - 1
			var itemsCount = gameIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = gameIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount, self.nextPageURL != nil {
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

			if indexPath.item >= itemsCount, self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchGames()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			guard let game = self.relatedGames[safe: indexPath.item]?.game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}
