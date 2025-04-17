//
//  GameDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

extension GameDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .badge:
			guard let gameDetailBadge = GameDetail.Badge(rawValue: indexPath.item) else { return }
			switch gameDetailBadge {
			case .rating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.rating) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .season:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: GameDetail.Information.publicationDates.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .rank:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: GameDetail.Information.genres.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .tvRating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: GameDetail.Information.rating.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .studio:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.moreByStudio) else { return }
				let indexPath = IndexPath(row: 0, section: sectionIndex)
				self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier, sender: indexPath)
				return
			case .country:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: GameDetail.Information.countryOfOrigin.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .language:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: GameDetail.Information.languages.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			}
		case .cast:
			guard let character = self.cast[indexPath]?.relationships.characters.data.first else { return }
			self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.characterDetailsSegue.identifier, sender: character)
		case .studios:
			guard let studio = self.studios[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.studioDetailsSegue.identifier, sender: studio)
		case .moreByStudio:
			guard let game = self.studioGames[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.gameDetailsSegue.identifier, sender: game)
		case .relatedGames:
			guard let game = self.relatedGames[safe: indexPath.item]?.game else { return }
			self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.gameDetailsSegue.identifier, sender: game)
		case .relatedShows:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return }
			self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
		case .relatedLiteratures:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return }
			self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.literatureDetailsSegue.identifier, sender: literature)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .header, .badge, .synopsis, .rateAndReview, .rating, .information, .sosumi:
			return nil
		case .reviews:
			return self.reviews[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .cast:
			return self.cast[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .studios:
			return self.studios[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .moreByStudio:
			return self.studioGames[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedGames:
			return self.relatedGames[indexPath.item].game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedShows:
			return self.relatedShows[indexPath.item].show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .relatedLiteratures:
			return self.relatedLiteratures[indexPath.item].literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
	}
}
