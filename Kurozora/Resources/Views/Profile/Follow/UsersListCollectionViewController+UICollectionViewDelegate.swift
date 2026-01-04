//
//  UsersListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension UsersListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let user = self.cache[indexPath] as? User else { return }
		self.show(SegueIdentifiers.userDetailsSegue, sender: user)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let showIdentitiesCount = self.userIdentities.count - 1
		var itemsCount = showIdentitiesCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = showIdentitiesCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount, self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchUsers()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let user = self.cache[indexPath] as? User else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		return user.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
