//
//  ThemesCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ThemesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let theme = self.dataSource.itemIdentifier(for: indexPath) else { return }
		self.performSegue(withIdentifier: R.segue.themesCollectionViewController.exploreSegue, sender: theme)
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		return self.dataSource.itemIdentifier(for: indexPath)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}

	override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let themeLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: themeLockupCollectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let themeLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: themeLockupCollectionViewCell, parameters: parameters)
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
