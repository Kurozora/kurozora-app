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
		switch self.libraryKind {
		case .shows:
			let show = self.shows[safe: indexPath.item]
			self.performSegue(withIdentifier: R.segue.favoritesCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			let literature = self.literatures[safe: indexPath.item]
			self.performSegue(withIdentifier: R.segue.favoritesCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			let game = self.games[safe: indexPath.item]
			self.performSegue(withIdentifier: R.segue.favoritesCollectionViewController.gameDetailsSegue, sender: game)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.libraryKind {
		case .shows:
			if indexPath.item == self.shows.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchFavoritesList()
				}
			}
		case .literatures:
			if indexPath.item == self.literatures.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchFavoritesList()
				}
			}
		case .games:
			if indexPath.item == self.games.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchFavoritesList()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.libraryKind {
		case .shows:
			return self.shows[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatures:
			return self.literatures[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .games:
			return self.games[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
	}
}
