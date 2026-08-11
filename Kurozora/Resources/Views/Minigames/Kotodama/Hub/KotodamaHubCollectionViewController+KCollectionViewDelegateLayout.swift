//
//  KotodamaHubCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension KotodamaHubCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		return 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch SectionLayoutKind(rawValue: section) {
		case .daily:
			return NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16)
		case .modes, .none:
			return NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 40, trailing: 16)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }

			let estimatedHeight: CGFloat = SectionLayoutKind(rawValue: section) == .daily ? 200 : 72
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(estimatedHeight)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(estimatedHeight)
			)
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = 12.0
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}, configuration: Self.readableLayoutConfiguration)
	}
}
