//
//  LiteratureDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension LiteratureDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .badge:
			guard let literatureDetailBadge = LiteratureDetail.Badge(rawValue: indexPath.item) else { return }
			switch literatureDetailBadge {
			case .rating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.rating) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .season:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: LiteratureDetail.Information.publicationDates.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .rank:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: LiteratureDetail.Information.genres.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .tvRating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: LiteratureDetail.Information.rating.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .studio:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.moreByStudio) else { return }
				let indexPath = IndexPath(row: 0, section: sectionIndex)
				self.performSegue(withIdentifier: R.segue.literatureDetailsCollectionViewController.literaturesListSegue.identifier, sender: indexPath)
				return
			case .language:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: LiteratureDetail.Information.languages.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			}
		case .cast:
			let character = self.cast[indexPath]?.relationships.characters.data.first
			self.performSegue(withIdentifier: R.segue.literatureDetailsCollectionViewController.characterDetailsSegue.identifier, sender: character)
		case .studios:
			let studio = self.studios[indexPath]
			self.performSegue(withIdentifier: R.segue.literatureDetailsCollectionViewController.studioDetailsSegue.identifier, sender: studio)
		case .moreByStudio:
			let literature = self.studioLiteratures[indexPath]
			self.performSegue(withIdentifier: R.segue.literatureDetailsCollectionViewController.literatureDetailsSegue.identifier, sender: literature)
		case .relatedLiteratures:
			let literature = self.relatedLiteratures[indexPath.item].literature
			self.performSegue(withIdentifier: R.segue.literatureDetailsCollectionViewController.literatureDetailsSegue.identifier, sender: literature)
		case .relatedShows:
			let show = self.relatedShows[indexPath.item].show
			self.performSegue(withIdentifier: R.segue.literatureDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .cast:
			return self.cast[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .studios:
			return self.studios[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .moreByStudio:
			return self.studioLiteratures[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedLiteratures:
			return self.relatedLiteratures[indexPath.item].literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedShows:
			return self.relatedShows[indexPath.item].show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
