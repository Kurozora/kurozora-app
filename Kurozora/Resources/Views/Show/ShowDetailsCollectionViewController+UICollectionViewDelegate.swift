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
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .badges:
			guard let showDetailBadge = ShowDetail.Badge(rawValue: indexPath.item) else { return }
			switch showDetailBadge {
			case .rating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.rating) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .season:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.airDates.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .rank:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.genres.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .tvRating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.rating.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .studio:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.moreByStudio) else { return }
				let indexPath = IndexPath(row: 0, section: sectionIndex)
				self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.showsListSegue.identifier, sender: indexPath)
				return
			case .country:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.countryOfOrigin.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .language:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.languages.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			}
		case .seasons:
			let season = self.seasons[indexPath]
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.episodesListSegue.identifier, sender: season)
		case .songs:
			let song = self.showSongs[indexPath.item].song
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.songDetailsSegue.identifier, sender: song)
		case .studios:
			let studio = self.studios[indexPath]
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.studioDetailsSegue.identifier, sender: studio)
		case .moreByStudio:
			let show = self.studioShows[indexPath]
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
		case .relatedShows:
			let show = self.relatedShows[indexPath.item].show
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
		case .relatedLiteratures:
			let literature = self.relatedLiteratures[indexPath.item].literature
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.literatureDetailsSegue.identifier, sender: literature)
		case .relatedGames:
			let game = self.relatedGames[indexPath.item].game
			self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.gameDetailsSegue.identifier, sender: game)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .reviews:
			return self.reviews[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .seasons:
			return self.seasons[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .cast:
			return self.cast[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .songs:
			guard let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell else { return nil }
			return self.showSongs[indexPath.item].song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": cell.song
			])
		case .studios:
			return self.studios[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .moreByStudio:
			return self.studioShows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedShows:
			return self.relatedShows[indexPath.item].show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedLiteratures:
			return self.relatedLiteratures[indexPath.item].literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedGames:
			return self.relatedGames[indexPath.item].game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default: break
		}

		return nil
	}
}
