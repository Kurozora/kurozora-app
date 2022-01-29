//
//  HomeCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let exploreCategory = self.exploreCategories[indexPath.section]

		switch exploreCategory.attributes.exploreCategoryType {
		case .shows, .upcomingShows, .mostPopularShows:
			let show = exploreCategory.relationships.shows?.data[indexPath.item]
			performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue, sender: show)
		case .genres:
			let genre = exploreCategory.relationships.genres?.data[indexPath.item]
			performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: genre)
		case .themes:
			let theme = exploreCategory.relationships.themes?.data[indexPath.item]
			performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: theme)
		case .characters:
			let character = exploreCategory.relationships.characters?.data[indexPath.item]
			performSegue(withIdentifier: R.segue.homeCollectionViewController.characterSegue, sender: character)
		case .people:
			let person = exploreCategory.relationships.people?.data[indexPath.item]
			performSegue(withIdentifier: R.segue.homeCollectionViewController.personSegue, sender: person)
		}

		if let legalCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LegalCollectionViewCell {
			performSegue(withIdentifier: R.segue.homeCollectionViewController.legalSegue, sender: legalCollectionViewCell)
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let exploreCategory = self.exploreCategories[indexPath.section]

		switch exploreCategory.attributes.exploreCategoryType {
		case .shows, .upcomingShows, .mostPopularShows:
			let show = exploreCategory.relationships.shows?.data[indexPath.item]
			return show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .genres:
			let genre = exploreCategory.relationships.genres?.data[indexPath.item]
			return genre?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .themes:
			let theme = exploreCategory.relationships.themes?.data[indexPath.item]
			return theme?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .characters:
			let character = exploreCategory.relationships.characters?.data[indexPath.item]
			return character?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .people:
			let person = exploreCategory.relationships.people?.data[indexPath.item]
			return person?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
