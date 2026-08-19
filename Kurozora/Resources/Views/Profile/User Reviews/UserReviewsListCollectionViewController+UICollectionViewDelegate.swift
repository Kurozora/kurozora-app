//
//  UserReviewsListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension UserReviewsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath),
			  case .review(let review) = itemKind else { return }

		if review.relationships?.literatures != nil {
			guard let literature: Literature = self.fetchModel(at: indexPath) else { return }
			self.show(.literatureDetailsSegue, sender: literature)
		} else if review.relationships?.characters != nil {
			guard let character: Character = self.fetchModel(at: indexPath) else { return }
			self.show(.characterDetailsSegue, sender: character)
		} else if review.relationships?.people != nil {
			guard let person: Person = self.fetchModel(at: indexPath) else { return }
			self.show(.personDetailsSegue, sender: person)
		} else if review.relationships?.episodes != nil {
			guard let episode: Episode = self.fetchModel(at: indexPath) else { return }
			self.show(.episodeDetailsSegue, sender: episode)
		} else if review.relationships?.games != nil {
			guard let game: Game = self.fetchModel(at: indexPath) else { return }
			self.show(.gameDetailsSegue, sender: game)
		} else if review.relationships?.shows != nil {
			guard let show: Show = self.fetchModel(at: indexPath) else { return }
			self.show(.showDetailsSegue, sender: show)
		} else if review.relationships?.songs != nil {
			guard let song: Song = self.fetchModel(at: indexPath) else { return }
			self.show(.songDetailsSegue, sender: song)
		} else if review.relationships?.studios != nil {
			guard let studio: Studio = self.fetchModel(at: indexPath) else { return }
			self.show(.studioDetailsSegue, sender: studio)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let reviewsCount = self.reviews.count - 1
		var itemsCount = reviewsCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = reviewsCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount && self.nextPageCursor != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath),
			  case .review(let review) = itemKind else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		return review.contextMenuConfiguration(in: self, userInfo: nil, sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
