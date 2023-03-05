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
		switch UserSettings.libraryKind {
		case .shows:
			let show = self.shows[safe: indexPath.item]
			self.performSegue(withIdentifier: R.segue.libraryListCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			let literature = self.literatures[safe: indexPath.item]
			self.performSegue(withIdentifier: R.segue.libraryListCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			let game = self.games[safe: indexPath.item]
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

	override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let collectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: collectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let collectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: collectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		if let previewViewController = animator.previewViewController {
			animator.addCompletion {
				self.show(previewViewController, sender: self)
			}
		}
	}
}
