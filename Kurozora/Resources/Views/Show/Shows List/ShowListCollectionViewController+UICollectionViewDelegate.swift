//
//  ShowListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ShowsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard self.shows[indexPath] != nil || self.relatedShows.indices.contains(indexPath.item) else { return }
		let segueIdentifier = R.segue.showsListCollectionViewController.showDetailsSegue
		self.performSegue(withIdentifier: segueIdentifier, sender: self.shows[indexPath] ?? self.relatedShows[indexPath.item].show)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			let showIdentitiesCount = self.relatedShows.count - 1
			var itemsCount = showIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = showIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchShows()
				}
			}
		default:
			let showIdentitiesCount = self.showIdentities.count - 1
			var itemsCount = showIdentitiesCount / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = showIdentitiesCount - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchShows()
				}
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			return self.relatedShows[safe: indexPath.item]?.show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default:
			guard self.shows[indexPath] != nil else { return nil }
			return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
