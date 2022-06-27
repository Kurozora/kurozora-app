//
//  SearchResultsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension SearchResultsCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .characters:
			columnCount = (width / 140.0).rounded().int
		case .people:
			columnCount = (width / 140.0).rounded().int
		case .songs:
			columnCount = (width / 250.0).rounded().int
		case .shows:
			if width >= 414.0 {
				columnCount = (width / 384.0).rounded().int
			} else {
				columnCount = (width / 284.0).rounded().int
			}
		case .studios:
			if width >= 414.0 {
				columnCount = (width / 384.0).rounded().int
			} else {
				columnCount = (width / 284.0).rounded().int
			}
		case .users:
			if width >= 414.0 {
				columnCount = (width / 384.0).rounded().int
			} else {
				columnCount = (width / 284.0).rounded().int
			}
		}

		switch section {
		case .shows, .studios:
			// Limit columns to 5 or less
			if columnCount > 5 {
				columnCount = 5
			}
		default: break
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let leadingInset = collectionView.directionalLayoutMargins.leading
		let trailingInset = collectionView.directionalLayoutMargins.trailing
		return NSDirectionalEdgeInsets(top: 20, leading: leadingInset, bottom: 20, trailing: trailingInset)
	}

	override func contentInset(forBackgroundInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let leadingInset = collectionView.directionalLayoutMargins.leading - 10.0
		let trailingInset = collectionView.directionalLayoutMargins.trailing - 10.0
		return NSDirectionalEdgeInsets(top: 10, leading: leadingInset, bottom: 10, trailing: trailingInset)
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let searchResultSection = self.dataSource.snapshot().sectionIdentifiers[section]
			let columns = self.columnCount(forSection: searchResultSection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil

			switch searchResultSection {
			case .characters:
				sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .people:
				sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .shows:
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: self.currentScope == .kurozora)
			case .songs:
				sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .studios:
				sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .users:
				sectionLayout = Layouts.usersSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			}

			if self.currentScope == .kurozora {
				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}
			return sectionLayout
		}
	}
}
