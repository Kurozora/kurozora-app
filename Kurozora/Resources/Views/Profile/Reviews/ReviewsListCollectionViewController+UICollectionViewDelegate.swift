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
		guard self.reviews[indexPath] != nil else { return }
		let review = self.reviews[indexPath]

		if let literature = review?.relationships?.literatures?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.literatureDetailsSegue, sender: literature)
		} else if let character = review?.relationships?.characters?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.characterDetailsSegue, sender: character)
		} else if let person = review?.relationships?.people?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.personDetailsSegue, sender: person)
		} else if let episode = review?.relationships?.episodes?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.episodeDetailsSegue, sender: episode)
		} else if let game = review?.relationships?.games?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.gameDetailsSegue, sender: game)
		} else if let show = review?.relationships?.shows?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.showDetailsSegue, sender: show)
		} else if let song = review?.relationships?.songs?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.songDetailsSegue, sender: song)
		} else if let studio = review?.relationships?.studios?.data.first {
			self.performSegue(withIdentifier: R.segue.reviewsListCollectionViewController.studioDetailsSegue, sender: studio)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let showIdentitiesCount = self.reviewIdentities.count - 1
		var itemsCount = showIdentitiesCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = showIdentitiesCount - itemsCount
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
		guard self.reviews[indexPath] != nil else { return nil }
		return self.reviews[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
	}
}
