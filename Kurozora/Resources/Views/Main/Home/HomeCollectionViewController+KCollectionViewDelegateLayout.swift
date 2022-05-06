//
//  HomeCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension HomeCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0
		let exploreCategoriesCount = self.exploreCategories.count

		switch self.dataSource.itemIdentifier(for: IndexPath(item: 0, section: section)) {
		case .show, .genre, .theme:
			switch section {
			case let section where section < exploreCategoriesCount:
				let exploreCategorySize = section != 0 ? self.exploreCategories[section].attributes.exploreCategorySize : .banner
				switch exploreCategorySize {
				case .banner:
					if width >= 414 {
						columnCount = (width / 562).rounded().int
					} else {
						columnCount = (width / 374).rounded().int
					}
				case .large:
					if width >= 414 {
						columnCount = (width / 500).rounded().int
					} else {
						columnCount = (width / 324).rounded().int
					}
				case .medium:
					if width >= 414 {
						columnCount = (width / 384).rounded().int
					} else {
						columnCount = (width / 284).rounded().int
					}
				case .small:
					if width >= 414 {
						columnCount = (width / 384).rounded().int
					} else {
						columnCount = (width / 284).rounded().int
					}
				case .upcoming:
					if width >= 414 {
						columnCount = (width / 384).rounded().int
					} else {
						columnCount = (width / 284).rounded().int
					}
				case .video:
					if width >= 414 {
						columnCount = (width / 500).rounded().int
					} else {
						columnCount = (width / 360).rounded().int
					}
				}
			default: break
			}
		case .showSong:
			columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			columnCount = columnCount > 8 ? 8 : columnCount
		case .character, .person:
			columnCount = UIDevice.isPhone ? (width / 200).rounded().int : (width / 300).rounded().int
		default:
			var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
			switch section {
			case let section where section == exploreCategoriesCount + 1:
				verticalCollectionCellStyle = .actionButton
			case let section where section == exploreCategoriesCount + 2:
				verticalCollectionCellStyle = .legal
			default: break
			}

			var numberOfItems = self.collectionView.numberOfItems(inSection: section)
			numberOfItems = numberOfItems > 0 ? numberOfItems : 1

			switch verticalCollectionCellStyle {
			case .actionList:
				let actionListCount = (width / 414).rounded().int
				columnCount = actionListCount > 5 ? 5 : actionListCount
			case .actionButton:
				let actionButtonCount = (width / 414).rounded().int
				columnCount = actionButtonCount > 2 ? 2 : actionButtonCount
			case .legal:
				columnCount = 1
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategoriesCount = self.exploreCategories.count
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			switch self.dataSource.itemIdentifier(for: IndexPath(item: 0, section: section)) {
			case .show, .genre, .theme:
				let exploreCategorySize = section != 0 ? self.exploreCategories[section].attributes.exploreCategorySize : .banner
				var sectionLayout: NSCollectionLayoutSection? = nil

				switch exploreCategorySize {
				case .banner:
					sectionLayout = Layouts.bannerSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					return sectionLayout
				case .large:
					sectionLayout = Layouts.largeSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .medium:
					sectionLayout = Layouts.mediumSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .small:
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .upcoming:
					sectionLayout = Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .video:
					sectionLayout = Layouts.videoSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				}

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]

				return sectionLayout
			case .showSong:
				let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
				let sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment)

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout.boundarySupplementaryItems = [sectionHeader]
				return sectionLayout
			case .character:
				let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
				let sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment)

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout.boundarySupplementaryItems = [sectionHeader]
				return sectionLayout
			case .person:
				let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
				let sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment)

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout.boundarySupplementaryItems = [sectionHeader]
				return sectionLayout
			default:
				var listSection: NSCollectionLayoutSection!

				switch section {
				case let section where section == exploreCategoriesCount + 1:
					listSection = Layouts.quickActionSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false, collectionView: self.collectionView)
				case let section where section == exploreCategoriesCount + 2:
					listSection = Layouts.legalSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				default:
					listSection = Layouts.quickLinkSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				}

				// Lists are 3 sections. This makes sure that only the top most section gets a header view (Quick Links).
				guard section == exploreCategoriesCount else { return listSection }

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				listSection.boundarySupplementaryItems = [sectionHeader]
				return listSection
			}
		}
	}
}
