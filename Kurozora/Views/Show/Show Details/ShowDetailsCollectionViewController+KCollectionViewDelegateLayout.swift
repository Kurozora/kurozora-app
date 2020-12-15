//
//  ShowDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

// MARK: - KCollectionViewDelegateLayout
extension ShowDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch ShowDetail.Section(rawValue: section) {
		case .header, .badge, .synopsis, .sosumi:
			return 1
		case .rating:
			if width > 828 {
				let columnCount = (width / 374).rounded().int
				if columnCount >= 3 {
					return 3
				} else if columnCount > 0 {
					return columnCount
				}
			}
			return 1
		case .seasons, .cast, .moreByStudio, .relatedShows:
			var columnCount = 1
			if width >= 414 {
				columnCount = (width / 414).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
			if columnCount > 5 {
				return 5
			}
			return columnCount
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func verticalColumnCount(for section: Int) -> Int {
		guard let showDetailSection = ShowDetail.Section(rawValue: section) else { return 1 }
		var itemsCount = 0
		switch showDetailSection {
		case .seasons:
			let seasonsCount = seasons.count
			if seasonsCount != 0 {
				itemsCount = seasonsCount
			}
		case .cast:
			let castCount = cast.count
			if castCount != 0 {
				itemsCount = castCount
			}
		case .moreByStudio:
			if let studioShowsCount = self.moreByStudio.relationships?.shows?.data.count, studioShowsCount != 0 {
				itemsCount = studioShowsCount
			}
		case .relatedShows:
			let relatedShowsCount = relatedShows.count
			if relatedShowsCount != 0 {
				itemsCount = relatedShowsCount
			}
		default: break
		}
		return itemsCount > 5 ? 2 : 1
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return .fractionalHeight(1.0)
		case .badge:
			return .estimated(50)
		case .synopsis:
			return .estimated(100)
		case .rating:
			return .absolute(88)
		case .information:
			return .estimated(55)
		case .seasons, .cast, .moreByStudio, .relatedShows:
			let verticalColumnCount = self.verticalColumnCount(for: section)
			return verticalColumnCount == 2 ? .estimated(400) : .estimated(200)
		case .sosumi:
			return .estimated(50)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	func widthDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch ShowDetail.Section(rawValue: section) {
		case .seasons, .cast, .moreByStudio, .relatedShows:
			let columnsCount = columnsCount <= 1 ? columnsCount : columnsCount - 1
			let widthFraction = self.groupWidthFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(widthFraction)
		default:
			return .fractionalWidth(1.0)
		}
	}

	func groupWidthFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		switch ShowDetail.Section(rawValue: section) {
		case .seasons:
			if seasons.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .cast:
			if cast.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .moreByStudio:
			if let showsCount = self.moreByStudio.relationships?.shows?.data.count, showsCount != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .relatedShows:
			if relatedShows.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		default: break
		}
		return .zero
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return .zero
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard let showDetailSection = ShowDetail.Section(rawValue: section) else { fatalError("ShowDetail section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false
			var hasBackgroundDecoration = false

			switch showDetailSection {
			case .header:
				let headerSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .synopsis:
				if let synopsis = self.show.attributes.synopsis, !synopsis.isEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .rating:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
				hasSectionHeader = true
			case .information:
				let listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = listSection
				hasSectionHeader = true
			case .seasons:
				let seasonsCount = self.seasons.count
				if seasonsCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .cast:
				let castCount = self.cast.count
				if castCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .moreByStudio:
				if let studioShowsCount = self.moreByStudio?.relationships?.shows?.data.count {
					if studioShowsCount != 0 {
						let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
						sectionLayout = gridSection
						hasSectionHeader = true
						hasBackgroundDecoration = true
					}
				}
			case .relatedShows:
				let relatedShowsCount = self.relatedShows.count
				if relatedShowsCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .sosumi:
				if let copyrightIsEmpty = self.show.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasBackgroundDecoration = true
				}
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
															  heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			if hasBackgroundDecoration {
				let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.elementKindSectionBackground)
				sectionLayout?.decorationItems = [sectionBackgroundDecoration]
			}

			return sectionLayout
		}
		layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		return layout
	}

	func headerSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func fullSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												heightDimension: heightDimension)
		let item = NSCollectionLayoutItem(layoutSize: layoutSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitem: item, count: columns)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func gridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(0.5))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let widthDimension = self.widthDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension,
											   heightDimension: heightDimension)
		let verticalColumnCount = self.verticalColumnCount(for: section)
		let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
														   subitem: item, count: verticalColumnCount)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func listSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
															 subitem: item, count: columns)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}
}
