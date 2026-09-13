//
//  SearchResultsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - UICollectionViewDelegate
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .discoverSuggestion: break
		case .browseCategory(let browseCategory):
			self.show(browseCategory.segueIdentifier ?? SegueIdentifiers.searchSegue, sender: browseCategory)
		case .characterIdentity:
			guard let character: Character = self.fetchModel(at: indexPath) else { return }
			self.show(.characterDetailsSegue, sender: character)
		case .episodeIdentity:
			guard let episode: Episode = self.fetchModel(at: indexPath) else { return }
			self.show(.episodeDetailsSegue, sender: episode)
		case .personIdentity:
			guard let person: Person = self.fetchModel(at: indexPath) else { return }
			self.show(.personDetailsSegue, sender: person)
		case .showIdentity(let identity):
			guard let show: Show = self.fetchModel(at: indexPath) else {
				self.show(ShowDetailsCollectionViewController()(with: identity.id), sender: nil)
				return
			}
			self.show(.showDetailsSegue, sender: show)
		case .literatureIdentity(let identity):
			guard let literature: Literature = self.fetchModel(at: indexPath) else {
				self.show(LiteratureDetailsCollectionViewController()(with: identity.id), sender: nil)
				return
			}
			self.show(.literatureDetailsSegue, sender: literature)
		case .gameIdentity(let identity):
			guard let game: Game = self.fetchModel(at: indexPath) else {
				self.show(GameDetailsCollectionViewController()(with: identity.id), sender: nil)
				return
			}
			self.show(.gameDetailsSegue, sender: game)
		case .songIdentity:
			guard let song: Song = self.fetchModel(at: indexPath) else { return }
			self.show(.songDetailsSegue, sender: song)
		case .studioIdentity:
			guard let studio: Studio = self.fetchModel(at: indexPath) else { return }
			self.show(.studioDetailsSegue, sender: studio)
		case .userIdentity:
			guard let user: User = self.fetchModel(at: indexPath) else { return }
			self.show(.userDetailsSegue, sender: user)
		case .show: break
		case .literature: break
		case .game: break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		var identitiesCount: Int = 0
		var type: SearchType = .shows
		var nextPageCursor: PageCursor?

		switch itemKind {
		case .discoverSuggestion: break
		case .browseCategory: break
		case .characterIdentity:
			identitiesCount = self.characterIdentities.count
			type = .characters
			nextPageCursor = self.characterNextPageCursor
		case .episodeIdentity:
			identitiesCount = self.episodeIdentities.count
			type = .episodes
			nextPageCursor = self.episodeNextPageCursor
		case .personIdentity:
			identitiesCount = self.personIdentities.count
			nextPageCursor = self.personNextPageCursor
			type = .people
		case .showIdentity:
			identitiesCount = self.showIdentities.count
			nextPageCursor = self.showNextPageCursor
			type = .shows
		case .literatureIdentity:
			identitiesCount = self.literatureIdentities.count
			nextPageCursor = self.literatureNextPageCursor
			type = .literatures
		case .gameIdentity:
			identitiesCount = self.gameIdentities.count
			nextPageCursor = self.gameNextPageCursor
			type = .games
		case .songIdentity:
			identitiesCount = self.songIdentities.count
			type = .songs
			nextPageCursor = self.songNextPageCursor
		case .studioIdentity:
			identitiesCount = self.studioIdentities.count
			nextPageCursor = self.studioNextPageCursor
			type = .studios
		case .userIdentity:
			identitiesCount = self.userIdentities.count
			nextPageCursor = self.userNextPageCursor
			type = .users
		case .show: break
		case .literature: break
		case .game: break
		}

		if identitiesCount != 0 {
			let itemsCount = identitiesCount - 1

			if indexPath.item == itemsCount, nextPageCursor != nil, !self.isRequestInProgress {
				self.performSearch(with: self.searchQuery, in: self.currentScope, for: [type], with: self.searchFilters[type] ?? nil, next: nextPageCursor, resettingResults: false)
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch itemKind {
		case .discoverSuggestion:
			return nil
		case .browseCategory(let browseCategory):
			let identifier = indexPath as NSCopying
			let segueIdentifier = browseCategory.segueIdentifier ?? SegueIdentifiers.searchSegue

			return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
				guard let self = self else { return nil }
				guard let destination = self.makeDestination(for: segueIdentifier) else { return nil }
				self.prepare(for: segueIdentifier, destination: destination, sender: browseCategory)
				return destination
			}, actionProvider: nil)
		case .characterIdentity:
			return (self.fetchModel(at: indexPath) as Character?)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .episodeIdentity:
			return (self.fetchModel(at: indexPath) as Episode?)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .personIdentity:
			return (self.fetchModel(at: indexPath) as Person?)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .showIdentity(let identity):
			guard let show: Show = self.fetchModel(at: indexPath) else {
				return self.libraryEntry(forTrackableID: identity.id.rawValue, kind: .shows)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			}
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .literatureIdentity(let identity):
			guard let literature: Literature = self.fetchModel(at: indexPath) else {
				return self.libraryEntry(forTrackableID: identity.id.rawValue, kind: .literatures)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			}
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .gameIdentity(let identity):
			guard let game: Game = self.fetchModel(at: indexPath) else {
				return self.libraryEntry(forTrackableID: identity.id.rawValue, kind: .games)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			}
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .songIdentity:
			guard
				let kkSong: Song = self.fetchModel(at: indexPath),
				let appleMusicID = kkSong.attributes.amID,
				let song = self.resolvedSongs[appleMusicID]
			else { return nil }
			return kkSong.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": song
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .studioIdentity:
			return (self.fetchModel(at: indexPath) as Studio?)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .userIdentity:
			return (self.fetchModel(at: indexPath) as User?)?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .show:
			return nil
		case .literature:
			return nil
		case .game:
			return nil
		}
	}
}
