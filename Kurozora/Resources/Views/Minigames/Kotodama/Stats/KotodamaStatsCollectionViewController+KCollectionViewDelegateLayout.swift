//
//  KotodamaStatsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension KotodamaStatsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		guard SectionLayoutKind(rawValue: section) == .summary else { return 1 }

		// One row wherever the values fit, then two rows, then a single column.
		let width = layoutEnvironment.container.effectiveContentSize.width

		for columns in [4, 2] {
			let spacing = CGFloat(columns - 1) * 10
			if (width - spacing) / CGFloat(columns) >= 132 {
				return columns
			}
		}

		return 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch SectionLayoutKind(rawValue: section) {
		case .summary:
			return NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16)
		case .distributionTitle:
			return NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
		case .distribution:
			return NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
		case .average, .none:
			return NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 40, trailing: 16)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }

			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let height: NSCollectionLayoutDimension = SectionLayoutKind(rawValue: section) == .distribution
				? .absolute(20)
				: .estimated(72)

			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
			layoutGroup.interItemSpacing = .fixed(10.0)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = SectionLayoutKind(rawValue: section) == .distribution ? 8.0 : 10.0
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
	}
}
