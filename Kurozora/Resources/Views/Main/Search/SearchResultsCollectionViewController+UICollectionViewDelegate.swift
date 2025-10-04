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
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .discoverSuggestion: break
		case .browseCategory(let browseCategory):
			self.performSegue(withIdentifier: browseCategory.segueIdentifier ?? R.segue.searchResultsCollectionViewController.searchSegue.identifier, sender: browseCategory)
		case .characterIdentity:
			guard let character = self.characters[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.characterDetailsSegue, sender: character)
		case .episodeIdentity:
			guard let episode = self.episodes[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.episodeDetailsSegue, sender: episode)
		case .personIdentity:
			guard let person = self.people[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.personDetailsSegue, sender: person)
		case .showIdentity:
			guard let show = self.shows[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.showDetailsSegue, sender: show)
		case .literatureIdentity:
			guard let literature = self.literatures[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.literatureDetailsSegue, sender: literature)
		case .gameIdentity:
			guard let game = self.games[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.gameDetailsSegue, sender: game)
		case .songIdentity:
			guard let song = self.songs[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.songDetailsSegue, sender: song)
		case .studioIdentity:
			guard let studio = self.studios[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.studioDetailsSegue, sender: studio)
		case .userIdentity:
			guard let user = self.users[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.userDetailsSegue, sender: user)
		case .show: break
		case .literature: break
		case .game: break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		var identitiesCount: Int = 0
		var type: KKSearchType = .shows
		var nextPageURL: String?

		switch itemKind {
		case .discoverSuggestion: break
		case .browseCategory: break
		case .characterIdentity:
			identitiesCount = self.characterIdentities.count
			type = .characters
			nextPageURL = self.characterNextPageURL
		case .episodeIdentity:
			identitiesCount = self.episodeIdentities.count
			type = .episodes
			nextPageURL = self.episodeNextPageURL
		case .personIdentity:
			identitiesCount = self.personIdentities.count
			nextPageURL = self.personNextPageURL
			type = .people
		case .showIdentity:
			identitiesCount = self.showIdentities.count
			nextPageURL = self.showNextPageURL
			type = .shows
		case .literatureIdentity:
			identitiesCount = self.literatureIdentities.count
			nextPageURL = self.literatureNextPageURL
			type = .literatures
		case .gameIdentity:
			identitiesCount = self.gameIdentities.count
			nextPageURL = self.gameNextPageURL
			type = .games
		case .songIdentity:
			identitiesCount = self.songIdentities.count
			type = .songs
			nextPageURL = self.songNextPageURL
		case .studioIdentity:
			identitiesCount = self.studioIdentities.count
			nextPageURL = self.studioNextPageURL
			type = .studios
		case .userIdentity:
			identitiesCount = self.userIdentities.count
			nextPageURL = self.userNextPageURL
			type = .users
		case .show: break
		case .literature: break
		case .game: break
		}

		if identitiesCount != 0 {
			let itemsCount = identitiesCount - 1

			if indexPath.item == itemsCount && nextPageURL != nil && !self.isRequestInProgress {
				self.performSearch(with: self.searchQuery, in: self.currentScope, for: [type], with: nil, next: nextPageURL, resettingResults: false)
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		switch itemKind {
		case .discoverSuggestion:
			return nil
		case .browseCategory:
			let browseCategory = self.browseCategories[indexPath.item]
			let identifier = indexPath as NSCopying

			return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
				guard let searchType = browseCategory.searchType else { return nil }
				let searchResultsCollectionViewController =
				R.storyboard.search.searchResultsCollectionViewController()
				searchResultsCollectionViewController?.title = browseCategory.title
				searchResultsCollectionViewController?.searchViewKind = .single(searchType)
				return searchResultsCollectionViewController
			}, actionProvider: nil)
		case .characterIdentity:
			return self.characters[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .episodeIdentity:
			return self.episodes[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .personIdentity:
			return self.people[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .showIdentity:
			guard let show = self.shows[indexPath] else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatureIdentity:
			guard let literature = self.literatures[indexPath] else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .gameIdentity:
			guard let game = self.games[indexPath] else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .songIdentity:
			guard let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell else { return nil }
			return self.songs[indexPath]?.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": cell.song
			])
		case .studioIdentity:
			return self.studios[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .userIdentity:
			return self.users[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .show:
			return nil
		case .literature:
			return nil
		case .game:
			return nil
		}
	}
}
