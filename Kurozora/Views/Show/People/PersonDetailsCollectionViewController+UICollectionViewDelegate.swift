//
//  PersonDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension PersonDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.personDetailsCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
		} else if let characterLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CharacterLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.personDetailsCollectionViewController.characterDetailsSegue, sender: characterLockupCollectionViewCell)
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let personDetailSection = PersonDetail.Section(rawValue: indexPath.section) else { return nil }
		switch personDetailSection {
		case .shows:
			if let smallLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? SmallLockupCollectionViewCell {
				return smallLockupCollectionViewCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		case .characters:
			if let characterLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CharacterLockupCollectionViewCell {
				return characterLockupCollectionViewCell.character?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		default: break
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
		if let previewViewController = animator.previewViewController {
			animator.addCompletion {
				self.show(previewViewController, sender: self)
			}
		}
	}
}
