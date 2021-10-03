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
		case .badge:
			guard let showDetailBadge = ShowDetail.Badge(rawValue: indexPath.item) else { return }
			switch showDetailBadge {
			case .rating:
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: ShowDetail.Section.rating.rawValue), at: .centeredVertically, animated: true)
				return
			case .season:
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.airDates.rawValue, section: ShowDetail.Section.information.rawValue), at: .centeredVertically, animated: true)
				return
			case .rank:
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.genres.rawValue, section: ShowDetail.Section.information.rawValue), at: .centeredVertically, animated: true)
				return
			case .tvRating:
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.rating.rawValue, section: ShowDetail.Section.information.rawValue), at: .centeredVertically, animated: true)
				return
			case .studio:
				segueIdentifier = R.segue.showDetailsCollectionViewController.studioSegue.identifier
			case .language:
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.languages.rawValue, section: ShowDetail.Section.information.rawValue), at: .centeredVertically, animated: true)
				return
			}
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
			if let posterLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? PosterLockupCollectionViewCell {
				return posterLockupCollectionViewCell.season?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
			if let smallLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? SmallLockupCollectionViewCell {
				return smallLockupCollectionViewCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
