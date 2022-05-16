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
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .banner(let exploreCategory), .small(let exploreCategory), .medium(let exploreCategory), .large(let exploreCategory), .upcoming(let exploreCategory), .video(let exploreCategory), .profile(let exploreCategory):
			switch exploreCategory.attributes.exploreCategoryType {
			case .mostPopularShows, .upcomingShows, .shows:
				let show = self.shows[indexPath]
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue, sender: show)
			case .genres:
				let genre = self.genres[indexPath]
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: genre)
			case .themes:
				let theme = self.themes[indexPath]
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: theme)
			case .characters:
				let character = self.characters[indexPath]
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.characterSegue, sender: character)
			case .people:
				let person = self.people[indexPath]
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.personSegue, sender: person)
			default: return
			}
		case .legal:
			self.performSegue(withIdentifier: R.segue.homeCollectionViewController.legalSegue, sender: nil)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section <= self.exploreCategories.count {
			let exploreCategory = self.exploreCategories[indexPath.section]

			switch exploreCategory.attributes.exploreCategoryType {
			case .shows, .upcomingShows, .mostPopularShows:
				return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			case .songs: break
			case .genres:
				return self.genres[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			case .themes:
				return self.themes[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			case .characters:
				return self.characters[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			case .people:
				return self.people[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
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
