//
//  SearchResultsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension SearchResultsCollectionViewController {
	func columnCount(forSection section: SearchResults.Section, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .characters, .people:
			columnCount = (width / 140.0).rounded().int
		case .episodes:
			if width >= 414.0 {
				columnCount = (width / 384.0).rounded().int
			} else {
				columnCount = (width / 284.0).rounded().int
			}
		case .songs:
			columnCount = (width / 250.0).rounded().int
		case .shows, .literatures, .games:
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
		case .discover:
			if width >= 414.0 {
				columnCount = (width / 384.0).rounded().int
			} else {
				columnCount = (width / 284.0).rounded().int
			}
		}

		switch section {
		case .shows, .literatures, .games, .studios:
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
			guard let searchResultSection = self.dataSource.snapshot().sectionIdentifiers[safe: section] else { return nil }
			let columns = self.columnCount(forSection: searchResultSection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasHeader: Bool = false

			switch searchResultSection {
			case .characters:
				hasHeader = false
				sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .episodes:
				hasHeader = false
				sectionLayout = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .people:
				hasHeader = false
				sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .shows, .literatures, .games:
				hasHeader = false
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .songs:
				hasHeader = false
				sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .studios:
				hasHeader = false
				sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .users:
				hasHeader = false
				sectionLayout = Layouts.usersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			case .discover:
				hasHeader = true
				sectionLayout = Layouts.usersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			if hasHeader {
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
