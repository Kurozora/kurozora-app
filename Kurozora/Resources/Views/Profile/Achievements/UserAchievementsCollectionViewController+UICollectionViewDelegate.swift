//
//  UserAchievementsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension UserAchievementsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let achievementsCount = self.achievements.count - 1
		var itemsCount = achievementsCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = achievementsCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount && self.nextPageCursor != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchAchievements()
			}
		}
	}
}
