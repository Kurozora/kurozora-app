//
//  ShowSongsListCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension ShowSongsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = (width / 254).rounded().int
		columnCount = columnCount > 8 ? 8 : columnCount
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let layoutSection = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)

			if self.showIdentity != nil {
				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				layoutSection.boundarySupplementaryItems = [sectionHeader]
			}
			return layoutSection
		}
		return layout
	}
}
