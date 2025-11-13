//
//  ReviewsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension ReviewsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if indexPath.item == self.reviews.count - 20, self.nextPageURL != nil {
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
			return self.reviews[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}
