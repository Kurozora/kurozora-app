//
//  SearchResultsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

// MARK: - UICollectionViewDelegate
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.itemIdentifier(for: indexPath) {
		case .characterIdentity:
			let character = self.characters[indexPath]
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.characterDetailsSegue, sender: character)
		case .episodeIdentity:
			let episode = self.episodes[indexPath]
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.episodeDetailsSegue, sender: episode)
		case .personIdentity:
			let person = self.people[indexPath]
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.personDetailsSegue, sender: person)
		case .showIdentity:
			guard let show = self.shows[indexPath] else { return }
			SearchHistory.saveContentsOf(show)
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.showDetailsSegue, sender: show)
		case .literatureIdentity:
			guard let literature = self.literatures[indexPath] else { return }
//			SearchHistory.saveContentsOf(literature)
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.literatureDetailsSegue, sender: literature)
		case .gameIdentity:
			guard let game = self.games[indexPath] else { return }
//			SearchHistory.saveContentsOf(game)
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.gameDetailsSegue, sender: game)
		case .songIdentity:
			let song = self.songs[indexPath]
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.songDetailsSegue, sender: song)
		case .studioIdentity:
			let studio = self.studios[indexPath]
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.studioDetailsSegue, sender: studio)
		case .userIdentity:
			let user = self.users[indexPath]
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.userDetailsSegue, sender: user)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.dataSource.itemIdentifier(for: indexPath) {
		case .characterIdentity:
			return self.characters[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .episodeIdentity:
			return self.episodes[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .personIdentity:
			return self.people[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .showIdentity:
			guard let show = self.shows[indexPath] else { return nil }
			SearchHistory.saveContentsOf(show)
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatureIdentity:
			guard let literature = self.literatures[indexPath] else { return nil }
//			SearchHistory.saveContentsOf(literature)
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .gameIdentity:
			guard let game = self.games[indexPath] else { return nil }
//			SearchHistory.saveContentsOf(game)
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .songIdentity:
			return self.songs[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .studioIdentity:
			return self.studios[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .userIdentity:
			return self.users[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default: return nil
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
