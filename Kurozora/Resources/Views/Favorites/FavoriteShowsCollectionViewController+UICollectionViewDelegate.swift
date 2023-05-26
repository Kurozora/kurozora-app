//
//  FavoritesCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension FavoritesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let show = self.shows[indexPath.item]
		performSegue(withIdentifier: R.segue.favoritesCollectionViewController.showDetailsSegue, sender: show)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if indexPath.item == self.shows.count - 20 && self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchFavoritesList()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return self.shows[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
	}
}
