//
//  HomeCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .banner(let exploreCategory), .episode(let exploreCategory), .small(let exploreCategory), .medium(let exploreCategory), .large(let exploreCategory), .upcoming(let exploreCategory), .video(let exploreCategory), .profile(let exploreCategory), .music(let exploreCategory):
			switch exploreCategory.attributes.exploreCategoryType {
			case .shows, .mostPopularShows, .upcomingShows, .newShows:
				guard let show = self.cache[indexPath] as? Show else { return }
				self.show(SegueIdentifiers.showDetailsSegue, sender: show)
			case .literatures, .mostPopularLiteratures, .upcomingLiteratures, .newLiteratures:
				guard let literature = self.cache[indexPath] as? Literature else { return }
				self.show(SegueIdentifiers.literatureDetailsSegue, sender: literature)
			case .games, .mostPopularGames, .upcomingGames, .newGames:
				guard let game = self.cache[indexPath] as? Game else { return }
				self.show(SegueIdentifiers.gameDetailsSegue, sender: game)
			case .episodes, .upNextEpisodes:
				guard let episode = self.cache[indexPath] as? Episode else { return }
				self.show(SegueIdentifiers.episodeDetailsSegue, sender: [indexPath: episode])
			case .genres:
				guard let genre = self.cache[indexPath] as? Genre else { return }
				self.show(SegueIdentifiers.exploreSegue, sender: genre)
			case .themes:
				guard let theme = self.cache[indexPath] as? Theme else { return }
				self.show(SegueIdentifiers.exploreSegue, sender: theme)
			case .characters:
				guard let character = self.cache[indexPath] as? Character else { return }
				self.show(SegueIdentifiers.characterSegue, sender: character)
			case .people:
				guard let person = self.cache[indexPath] as? Person else { return }
				self.show(SegueIdentifiers.personSegue, sender: person)
			case .songs:
				guard let showSong = self.cache[indexPath] as? ShowSong else { return }
				self.show(SegueIdentifiers.songDetailsSegue, sender: showSong.song)
			case .recap:
				guard let recap = self.cache[indexPath] as? Recap else { return }
				self.show(SegueIdentifiers.reCapSegue, sender: recap)
			}
		case .legal:
			self.present(SegueIdentifiers.legalSegue, sender: nil)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let exploreCategory = self.exploreCategories[safe: indexPath.section] else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch exploreCategory.attributes.exploreCategoryType {
		case .shows, .upcomingShows, .mostPopularShows, .newShows:
			guard let show = self.cache[indexPath] as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .literatures, .upcomingLiteratures, .mostPopularLiteratures, .newLiteratures:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .games, .upcomingGames, .mostPopularGames, .newGames:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .episodes, .upNextEpisodes:
			guard let episode = self.cache[indexPath] as? Episode else { return nil }
			return episode.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .songs:
			guard
				let musicLockupCollectionViewCell = collectionViewCell as? MusicLockupCollectionViewCell,
				let song = musicLockupCollectionViewCell.song,
				let showSong = self.cache[indexPath] as? ShowSong
			else { return nil }
			return showSong.song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": song
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .genres:
			guard let genres = self.cache[indexPath] as? Genre else { return nil }
			return genres.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .themes:
			guard let themes = self.cache[indexPath] as? Theme else { return nil }
			return themes.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .characters:
			guard let character = self.cache[indexPath] as? Character else { return nil }
			return character.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .people:
			guard let person = self.cache[indexPath] as? Person else { return nil }
			return person.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .recap:
			guard let recap = self.cache[indexPath] as? Recap else { return nil }
			let identifier = indexPath as NSCopying

			return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
				let reCapCollectionViewController = ReCapCollectionViewController()
				reCapCollectionViewController.year = recap.attributes.year
				reCapCollectionViewController.month = recap.attributes.month
				return reCapCollectionViewController
			})
		}
	}
}
