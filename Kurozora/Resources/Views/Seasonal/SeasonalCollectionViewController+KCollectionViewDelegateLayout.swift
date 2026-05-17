//
//  SeasonalCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SeasonalCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .browseSeason:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		}

		switch section {
		case .browseSeason:
			if columnCount > 5 {
				columnCount = 5
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch self.snapshot.sectionIdentifiers[section] {
		case .browseSeason:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let browseSeasonSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: browseSeasonSection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection?

			switch browseSeasonSection {
			case .browseSeason:
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
			)
			sectionLayout?.boundarySupplementaryItems = [sectionHeader]

			sectionLayout?.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return sectionLayout
		}

		return layout
	}
}
