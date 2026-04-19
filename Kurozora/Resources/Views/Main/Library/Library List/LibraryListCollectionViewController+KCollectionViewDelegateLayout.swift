//
//  LibraryListCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LibraryListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		switch self.effectiveCellStyle(for: layoutEnvironment) {
		case .compact:
			var columnCount = Int((width / 105).rounded())

			if columnCount <= 0 {
				columnCount = 3
			} else if columnCount > 8 {
				columnCount = 8
			} else {
				columnCount = Int(abs(Double(columnCount) / 1.5).rounded())
			}

			return columnCount
		case .detailed, .list, .table:
			var columnCount = Int((width / 374).rounded())

			if columnCount <= 0 {
				columnCount = 1
			} else if columnCount > 5 {
				columnCount = 5
			}

			return columnCount
		}
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}

			let effectiveStyle = self.effectiveCellStyle(for: layoutEnvironment)

			if effectiveStyle == .table {
				return self.makeTableSection(layoutEnvironment: layoutEnvironment)
			}

			return self.makeGridSection(section: section, layoutEnvironment: layoutEnvironment)
		}
	}

	// MARK: - Helpers
	/// Returns the cell style that drives the layout for the given environment.
	///
	/// - Parameter layoutEnvironment: The layout environment supplied by the compositional layout.
	///
	/// - Returns: The effective cell style for the environment.
	func effectiveCellStyle(for layoutEnvironment: NSCollectionLayoutEnvironment) -> KKLibrary.CellStyle {
		guard self.libraryCellStyle == .table else {
			return self.libraryCellStyle
		}

		if layoutEnvironment.traitCollection.horizontalSizeClass == .compact {
			return .list
		}

		return .table
	}

	private func makeGridSection(section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10.0)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 10.0
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	private func makeTableSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let rowHeight = self.tableRowHeight()

		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(rowHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(rowHeight))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 0
		section.contentInsets = self.contentInset(forSection: 0, layout: layoutEnvironment)

		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(32))
		let header = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .top
		)
		header.pinToVisibleBounds = true
		section.boundarySupplementaryItems = [header]

		return section
	}

	/// Returns the row height for the table section.
	///
	/// - Returns: The row height in points.
	private func tableRowHeight() -> CGFloat {
		guard self.libraryColumnPreferences.showPoster else {
			#if targetEnvironment(macCatalyst)
			return 48
			#else
			return 56
			#endif
		}

		let posterHeight: CGFloat = self.libraryKind == .games ? 80 : 120
		return posterHeight + 2 * LibraryTableCollectionViewCell.rowVerticalPadding
	}
}
