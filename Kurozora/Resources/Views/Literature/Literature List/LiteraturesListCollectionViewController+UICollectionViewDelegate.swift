//
//  LiteraturesListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LiteraturesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let literature = self.cache[indexPath] as? Literature
		let relatedLiterature = self.relatedLiteratures[safe: indexPath.item]?.literature
		guard let literature = literature ?? relatedLiterature else { return }
		let segueIdentifier = R.segue.literaturesListCollectionViewController.literatureDetailsSegue
		self.performSegue(withIdentifier: segueIdentifier, sender: literature)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			let literatureIdentitiesCount = self.relatedLiteratures.count - 1
			var itemsCount = literatureIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = literatureIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount, self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchLiteratures()
				}
			}
		default:
			let literatureIdentitiesCount = self.literatureIdentities.count - 1
			var itemsCount = literatureIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = literatureIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount, self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchLiteratures()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}
