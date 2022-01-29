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
				self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.studioSegue.identifier, sender: nil)
			case .language:
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.languages.rawValue, section: ShowDetail.Section.information.rawValue), at: .centeredVertically, animated: true)
				return
			}
		case .seasons:
			let season = self.seasons[indexPath.item]
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.episodeSegue.identifier, sender: season)
		case .moreByStudio:
			let show = self.studioShows[indexPath.item]
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
		case .relatedShows:
			let show = self.relatedShows[indexPath.item].show
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { return nil }

		switch showDetailSection {
		case .seasons:
			let season = self.seasons[indexPath.item]
			return season.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .cast:
			let cast = self.cast[indexPath.item]
			return cast.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .moreByStudio:
			let show = self.studioShows[indexPath.item]
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedShows:
			let show = self.relatedShows[indexPath.item].show
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
