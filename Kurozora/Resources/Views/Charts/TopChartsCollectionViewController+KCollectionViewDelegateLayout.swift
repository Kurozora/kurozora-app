//
//  TopChartsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension TopChartsCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .chart(let chartKind):
			switch chartKind {
			case .shows, .literatures, .games, .episodes, .studios:
				if width >= 414 {
					columnCount = Int((width / 384).rounded())
				} else {
					columnCount = Int((width / 284).rounded())
				}
			case .characters, .people:
				columnCount = Int((width / 140.0).rounded())
			case .songs:
				columnCount = Int((width / 250.0).rounded())
			}

			switch chartKind {
			case .shows, .literatures, .games:
				// Limit columns to 5 or less
				if columnCount > 5 {
					columnCount = 5
				}
			default: break
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard let snapshot = self.snapshot, let chartSection = snapshot.sectionIdentifiers[safe: section] else { return nil }
			let columns = self.columnCount(forSection: chartSection, layout: layoutEnvironment)
			let sectionLayout: NSCollectionLayoutSection

			switch chartSection {
			case .chart(let chartKind):
				switch chartKind {
				case .shows, .literatures, .games:
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .characters:
					sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .people:
					sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .episodes:
					sectionLayout = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .songs:
					sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .studios:
					sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				}
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
			)
			sectionLayout.boundarySupplementaryItems = [sectionHeader]
			return sectionLayout
		}
	}
}
