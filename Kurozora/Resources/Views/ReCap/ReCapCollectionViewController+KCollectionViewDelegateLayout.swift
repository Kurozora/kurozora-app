//
//  ReCapCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ReCapCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .header:
			return 1
		case .topShows, .topGames, .topLiteratures, .topGenres, .topThemes:
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		case .milestones(let isFullSection):
			if isFullSection {
				columnCount = 1
			} else if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		}

		switch section {
		case .topShows, .topGames, .topLiteratures:
			// Limit columns to 5 or less
			if columnCount > 5 {
				columnCount = 5
			}
		default: break
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let width = collectionViewLayout.container.effectiveContentSize.width

		switch self.snapshot.sectionIdentifiers[section] {
		case .header:
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		default:
			let bottom: CGFloat = if width >= 414 {
				144.0
			} else {
				40.0
			}

			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottom, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategorySection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: exploreCategorySection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil

			switch exploreCategorySection {
			case .header:
				sectionLayout = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				return sectionLayout
			case .topShows, .topGames, .topLiteratures:
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .topGenres, .topThemes:
				sectionLayout = Layouts.mediumSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .milestones(let isFullSection):
				if isFullSection {
					sectionLayout = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				} else {
					sectionLayout = Layouts.mediumSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				}
				return sectionLayout
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
			sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			sectionLayout?.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return sectionLayout
		}
	}
}
