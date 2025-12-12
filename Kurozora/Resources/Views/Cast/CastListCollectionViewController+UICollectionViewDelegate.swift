//
//  CastListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension CastListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.castKind {
		case .show, .game:
			break
		case .literature:
			guard
				let cast = self.cache[indexPath] as? Cast,
				let character = cast.relationships.characters.data.first
			else { return }

			self.performSegue(withIdentifier: SegueIdentifiers.characterDetailsSegue, sender: character)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let castIdentities = self.castIdentities.count - 1
		var itemsCount = castIdentities / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = castIdentities - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount, self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchCast()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let cast = self.cache[indexPath] as? Cast else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		return cast.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
