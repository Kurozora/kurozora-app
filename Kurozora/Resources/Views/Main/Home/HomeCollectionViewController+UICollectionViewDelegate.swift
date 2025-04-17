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
		case .banner(let exploreCategory), .episode(let exploreCategory), .small(let exploreCategory), .medium(let exploreCategory), .large(let exploreCategory), .upcoming(let exploreCategory), .video(let exploreCategory), .profile(let exploreCategory), .music(let exploreCategory):
			switch exploreCategory.attributes.exploreCategoryType {
			case .shows, .mostPopularShows, .upcomingShows, .newShows:
				guard let show = self.shows[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue, sender: show)
			case .literatures, .mostPopularLiteratures, .upcomingLiteratures, .newLiteratures:
				guard let literature = self.literatures[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.literatureDetailsSegue, sender: literature)
			case .games, .mostPopularGames, .upcomingGames, .newGames:
				guard let game = self.games[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.gameDetailsSegue, sender: game)
			case .episodes, .upNextEpisodes:
				guard let episode = self.episodes[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.episodeDetailsSegue, sender: [indexPath: episode])
			case .genres:
				guard let genre = self.genres[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: genre)
			case .themes:
				guard let theme = self.themes[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: theme)
			case .characters:
				guard let character = self.characters[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.characterSegue, sender: character)
			case .people:
				guard let person = self.people[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.personSegue, sender: person)
			case .songs:
				guard let song = self.showSongs[indexPath]?.song else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.songDetailsSegue, sender: song)
			case .recap:
				guard let recap = self.recaps[indexPath] else { return }
				self.performSegue(withIdentifier: R.segue.homeCollectionViewController.reCapSegue, sender: recap)
			}
		case .legal:
			self.performSegue(withIdentifier: R.segue.homeCollectionViewController.legalSegue, sender: nil)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let exploreCategory = self.exploreCategories[safe: indexPath.section] else { return nil }

		switch exploreCategory.attributes.exploreCategoryType {
		case .shows, .upcomingShows, .mostPopularShows, .newShows:
			return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatures, .upcomingLiteratures, .mostPopularLiteratures, .newLiteratures:
			return self.literatures[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .games, .upcomingGames, .mostPopularGames, .newGames:
			return self.games[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .episodes, .upNextEpisodes:
			return self.episodes[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .songs:
			guard let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell else { return nil }
			return self.showSongs[indexPath]?.song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": cell.song
			])
		case .genres:
			return self.genres[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .themes:
			return self.themes[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .characters:
			return self.characters[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .people:
			return self.people[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .recap:
			guard let recap = self.recaps[indexPath] else { return nil }
			let identifier = indexPath as NSCopying

			return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
				guard let reCapCollectionViewController = R.storyboard.reCap.reCapCollectionViewController() else { return nil }
				reCapCollectionViewController.year = recap.attributes.year
				reCapCollectionViewController.month = recap.attributes.month
				return reCapCollectionViewController
			})
		}
	}
}
