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
		case .header, .synopsis, .sosumi:
			return 1
		case .badge:
			return width > 414 ? ShowDetail.Badge.allCases.count : (width / 132).rounded().int
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
		case .information:
			let columnCount = width >= 414 ? (width / 200).rounded().int : (width / 160).rounded().int
			return columnCount > 0 ? columnCount : 2
		case .seasons:
			let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			return columnCount > 0 ? columnCount : 1
		case .cast:
			let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			return columnCount > 0 ? columnCount : 1
		case .moreByStudio, .relatedShows:
			let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			return columnCount > 0 ? columnCount : 1
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
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
			return .fractionalHeight(1.0)
		case .sosumi:
			return .estimated(50)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		case .information:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		case .sosumi:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self, self.show != nil else { return nil }
			guard let showDetailSection = ShowDetail.Section(rawValue: section) else { fatalError("ShowDetail section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false
			var hasBackgroundDecoration = false

			switch showDetailSection {
			case .header:
				let headerSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let badgeSection = self.badgeSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = badgeSection
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
				let listSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = listSection
				hasSectionHeader = true
			case .seasons:
				let seasonsCount = self.seasons.count
				if seasonsCount != 0 {
					let seasonsSectionLayout = self.seasonsSectionLayout(section, layoutEnvironment: layoutEnvironment)
					sectionLayout = seasonsSectionLayout
					hasSectionHeader = true
				}
			case .cast:
				let castCount = self.cast.count
				if castCount != 0 {
					let castSectionLayout = self.castSectionLayout(section, layoutEnvironment: layoutEnvironment)
					sectionLayout = castSectionLayout
					hasSectionHeader = true
				}
			case .moreByStudio:
				if let studioShowsCount = self.moreByStudio?.relationships?.shows?.data.count {
					if studioShowsCount != 0 {
						let showsSectionLayout = self.showsSectionLayout(section, layoutEnvironment: layoutEnvironment)
						sectionLayout = showsSectionLayout
						hasSectionHeader = true
						hasBackgroundDecoration = true
					}
				}
			case .relatedShows:
				let relatedShowsCount = self.relatedShows.count
				if relatedShowsCount != 0 {
					let showsSectionLayout = self.showsSectionLayout(section, layoutEnvironment: layoutEnvironment)
					sectionLayout = showsSectionLayout
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
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func fullSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)

		let item = NSCollectionLayoutItem(layoutSize: layoutSize)

		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitem: item, count: columns)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func badgeSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var item: NSCollectionLayoutItem!
		var layoutGroup: NSCollectionLayoutGroup!

		if width > 828 {
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		} else {
			let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100.0), heightDimension: .estimated(50.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100.0), heightDimension: .estimated(50.0))
			layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		}

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func seasonsSectionLayout(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .estimated(150.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10.0)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 10.0
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		return layoutSection
	}

	func castSectionLayout(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .estimated(150.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10.0)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 10.0
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		return layoutSection
	}

	func showsSectionLayout(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .estimated(150.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10.0)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 10.0
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

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func gridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(10.0)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		layoutSection.interGroupSpacing = 10.0
		return layoutSection
	}
}
