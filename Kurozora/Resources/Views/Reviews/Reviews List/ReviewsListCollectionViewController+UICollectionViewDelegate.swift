//
//  ReviewsListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension ReviewsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .reviews:
			guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

			switch itemKind {
			case .review(let review, _):
				self.present(.reviewDetailsSegue, sender: review)
			case .lowEffortReviewsToggle:
				self.toggleLowEffortReviewsVisibility()
			default: break
			}
		default: break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard self.snapshot.sectionIdentifiers[safe: indexPath.section] == .reviews else { return }

		// Counted against the rendered rows, since collapsing the low-effort ones shortens the section.
		let itemCount = collectionView.numberOfItems(inSection: indexPath.section)

		if indexPath.item >= max(itemCount - 20, 0), self.nextPageCursor != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .rateAndReview:
			return nil
		case .rating:
			return nil
		case .reviews:
			guard
				let itemKind = self.dataSource.itemIdentifier(for: indexPath),
				case .review(let review, _) = itemKind
			else { return nil }

			return review.contextMenuConfiguration(in: self, userInfo: [:], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}
