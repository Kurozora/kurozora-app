//
//  ParentalGuideCategoryEntriesCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension ParentalGuideCategoryEntriesCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		return 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { _, _ in
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(80)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(80)
			)
			let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

			let layoutSection = NSCollectionLayoutSection(group: group)
			layoutSection.interGroupSpacing = 8
			layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)

			return layoutSection
		}
	}
}
