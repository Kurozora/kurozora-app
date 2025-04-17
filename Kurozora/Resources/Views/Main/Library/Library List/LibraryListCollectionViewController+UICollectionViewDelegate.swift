//
//  LibraryListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension LibraryListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard !self.isEditing else { return }

		switch UserSettings.libraryKind {
		case .shows:
			guard let show = self.shows[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: R.segue.libraryListCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			guard let literature = self.literatures[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: R.segue.libraryListCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			guard let game = self.games[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: R.segue.libraryListCollectionViewController.gameDetailsSegue, sender: game)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch UserSettings.libraryKind {
		case .shows:
			if indexPath.item == self.shows.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchLibrary()
				}
			}
		case .literatures:
			if indexPath.item == self.literatures.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchLibrary()
				}
			}
		case .games:
			if indexPath.item == self.games.count - 20 && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchLibrary()
				}
			}
		}
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		if self.isEditing != editing {
			super.setEditing(editing, animated: animated)
			self.collectionView.isEditing = editing

			// Reload visible items to make sure our collection view cells show their selection indicators.
			var snapshot = self.dataSource.snapshot()
			snapshot.reconfigureItems(snapshot.itemIdentifiers)
			self.dataSource.apply(snapshot, animatingDifferences: true)

			if !editing {
				// Clear selection if leaving edit mode.
				self.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
					self.collectionView.deselectItem(at: indexPath, animated: animated)
				}
			}

//			self.updateNavigationBar()
		}
	}

	override func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
		self.setEditing(true, animated: true)
	}

	override func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
		print("\(#function)")
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch UserSettings.libraryKind {
		case .shows:
			return self.shows[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatures:
			return self.literatures[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .games:
			return self.games[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
	}
}
