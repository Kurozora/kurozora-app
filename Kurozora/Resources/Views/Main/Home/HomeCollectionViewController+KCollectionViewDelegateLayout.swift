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

	override func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let exploreCategoriesCount = self.exploreCategories.count

		switch section {
		case let section where section < exploreCategoriesCount:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
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
			case .actionButton:
				let leadingInset = self.collectionView.directionalLayoutMargins.leading
				let trailingInset = self.collectionView.directionalLayoutMargins.trailing
				return NSDirectionalEdgeInsets(top: 0, leading: leadingInset, bottom: 20, trailing: trailingInset)
			case .legal:
				return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
			default:
				return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
			}
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategoriesCount = self.exploreCategories.count

			switch self.dataSource.itemIdentifier(for: IndexPath(item: 0, section: section)) {
			case .show, .genre, .theme:
				let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
				let exploreCategorySize = section != 0 ? self.exploreCategories[section].attributes.exploreCategorySize : .banner
				var sectionLayout: NSCollectionLayoutSection? = nil

				switch exploreCategorySize {
				case .banner:
					sectionLayout = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					return sectionLayout
				case .large:
					sectionLayout = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
				case .medium:
					sectionLayout = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
				case .small:
					sectionLayout = Layouts.smallSectionLayout(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .upcoming:
					sectionLayout = Layouts.upcomingSectionLayout(section, columns: columns, layoutEnvironment: layoutEnvironment)
				case .video:
					sectionLayout = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
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
				let sectionLayout = Layouts.musicSectionLayout(section, columns: columns, layoutEnvironment: layoutEnvironment)

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout.boundarySupplementaryItems = [sectionHeader]
				return sectionLayout
			case .character:
				let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
				let sectionLayout = Layouts.charactersSectionLayout(section, columns: columns, layoutEnvironment: layoutEnvironment)

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout.boundarySupplementaryItems = [sectionHeader]
				return sectionLayout
			case .person:
				let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
				let sectionLayout = Layouts.peopleSectionLayout(section, columns: columns, layoutEnvironment: layoutEnvironment)

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
					listSection = self.quickActionSectionLayout(for: section, layoutEnvironment: layoutEnvironment)
				default:
					listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)
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

	func gridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .estimated(200.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .estimated(200.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
			guard let self = self else { return }
			visibleItems.forEach { item in
				guard let cell = self.collectionView.cellForItem(at: item.indexPath) as? VideoLockupCollectionViewCell else { return }

				if cell.avQueuePlayer.items().count > 0 {
					let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)

					if distanceFromCenter / environment.container.contentSize.width < 0.6 {
						cell.avQueuePlayer.play()
					} else {
						cell.avQueuePlayer.pause()
					}
				}
			}
		}
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		return layoutSection
	}

	func listSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(55))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func quickActionSectionLayout(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}
}
