//
//  ShowDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ShowDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { return }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		var segueIdentifier = ""

		switch showDetailSection {
		case .seasons:
			segueIdentifier = R.segue.showDetailsCollectionViewController.episodeSegue.identifier
		case .moreByStudio, .relatedShows:
			segueIdentifier = R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier
		default: return
		}

		self.performSegue(withIdentifier: segueIdentifier, sender: collectionViewCell)
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { return nil }

		switch showDetailSection {
		case .seasons:
			if let lockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LockupCollectionViewCell {
				return lockupCollectionViewCell.season?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		case .cast:
			if let castCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CastCollectionViewCell {
				return castCollectionViewCell.cast?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		case .moreByStudio:
			if let smallLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? SmallLockupCollectionViewCell {
				return smallLockupCollectionViewCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		case .relatedShows:
			if let lockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LockupCollectionViewCell {
				return lockupCollectionViewCell.relatedShow?.show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
