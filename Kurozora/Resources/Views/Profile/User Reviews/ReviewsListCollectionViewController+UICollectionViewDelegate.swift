//
//  ReviewsListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

extension ReviewsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let review = self.dataSource.itemIdentifier(for: indexPath) else { return }

		if review.relationships?.literatures != nil {
			let literature = self.fetchLiterature(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.literatureDetailsSegue, sender: literature)
		} else if review.relationships?.characters != nil {
			let character = self.fetchCharacter(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.characterDetailsSegue, sender: character)
		} else if review.relationships?.people != nil {
			let person = self.fetchPerson(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.personDetailsSegue, sender: person)
		} else if review.relationships?.episodes != nil {
			let episode = self.fetchEpisode(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.episodeDetailsSegue, sender: episode)
		} else if review.relationships?.games != nil {
			let game = self.fetchGame(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.gameDetailsSegue, sender: game)
		} else if review.relationships?.shows != nil {
			let show = self.fetchShow(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.showDetailsSegue, sender: show)
		} else if review.relationships?.songs != nil {
			let song = self.fetchSong(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.songDetailsSegue, sender: song)
		} else if review.relationships?.studios != nil {
			let studio = self.fetchStudio(at: indexPath)
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.studioDetailsSegue, sender: studio)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let reviewsCount = self.reviews.count - 1
		var itemsCount = reviewsCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = reviewsCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount && self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let review = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
		return review.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
	}
}
