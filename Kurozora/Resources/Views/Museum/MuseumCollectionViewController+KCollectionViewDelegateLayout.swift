//
//  MuseumCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension MuseumCollectionViewController {
	override func createLayout() -> UICollectionViewLayout? {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = .horizontal
		configuration.contentInsetsReference = .none

		let layout = MuseumHallLayout(sectionProvider: { [weak self] (section: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let rows = self.hallRowCount
			let columnHeight = CGFloat(rows) * (self.hallItemSize.height + Metrics.gap) - Metrics.gap

			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(self.hallItemSize.height))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(self.hallItemSize.width), heightDimension: .absolute(columnHeight))
			let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: rows)
			layoutGroup.interItemSpacing = .fixed(Metrics.gap)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = Metrics.gap
			layoutSection.contentInsets = NSDirectionalEdgeInsets(
				top: 0.0,
				leading: section == 0 ? Metrics.hallInset : 0.0,
				bottom: 0.0,
				trailing: Metrics.sectionSpacing
			)
			return layoutSection
		}, configuration: configuration)

		layout.columnHeightProvider = { [weak self] in
			guard let self = self else { return 0.0 }
			return CGFloat(self.hallRowCount) * (self.hallItemSize.height + Metrics.gap) - Metrics.gap
		}

		return layout
	}
}
