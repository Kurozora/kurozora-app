//
//  PeopleListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension PeopleListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let person = self.cache[indexPath] as? Person else { return }
		let segueIdentifier = R.segue.peopleListCollectionViewController.personDetailsSegue

		self.performSegue(withIdentifier: segueIdentifier, sender: person)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let showIdentitiesCount = self.personIdentities.count - 1
		var itemsCount = showIdentitiesCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = showIdentitiesCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount, self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchPeople()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let person = self.cache[indexPath] as? Person else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		return person.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
