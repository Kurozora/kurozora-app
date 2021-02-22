//
//  HomeCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			if self.exploreCategories[indexPath.section].relationships.shows != nil {
				performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell.show?.id)
			} else {
				performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: baseLockupCollectionViewCell.genre)
			}
		} else if let legalCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LegalCollectionViewCell {
			performSegue(withIdentifier: R.segue.homeCollectionViewController.legalSegue, sender: legalCollectionViewCell)
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			guard self.exploreCategories[indexPath.section].relationships.shows != nil else { return nil }
			return baseLockupCollectionViewCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
		return nil
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
		animator.addCompletion {
			if let previewViewController = animator.previewViewController {
				self.show(previewViewController, sender: self)
			}
		}
	}
}
