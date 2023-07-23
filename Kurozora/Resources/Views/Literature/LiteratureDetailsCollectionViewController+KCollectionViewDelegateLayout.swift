//
//  LiteratureDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

// MARK: - KCollectionViewDelegateLayout
extension LiteratureDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 1

		switch self.snapshot.sectionIdentifiers[section] {
		case .header, .synopsis, .sosumi:
			return 1
		case .badge:
			return width > 414 ? LiteratureDetail.Badge.allCases.count : (width / 132).rounded().int
		case .rating:
			let columnCount = (width / 250).rounded().int
			return columnCount >= 3 ? 3 : 2
		case .reviews: break
		case .information:
			columnCount = width >= 414 ? (width / 200).rounded().int : (width / 160).rounded().int
			return columnCount > 0 ? columnCount : 2
		case .cast:
			columnCount = (width / 140.0).rounded().int
		case .studios:
			columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			if columnCount > 5 {
				return 5
			}
		case .moreByStudio, .relatedLiteratures, .relatedShows, .relatedGames:
			columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			if columnCount > 5 {
				return 5
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch self.snapshot.sectionIdentifiers[section] {
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
			return .fractionalWidth(.zero)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch self.snapshot.sectionIdentifiers[section] {
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
			guard let self = self else { return nil }
			guard self.literature != nil else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false
			var hasBackgroundDecoration = false

			switch self.snapshot.sectionIdentifiers[section] {
			case .header:
				let headerSection = self.headerSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let badgeSection = self.badgeSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = badgeSection
			case .synopsis:
				if let synopsis = self.literature.attributes.synopsis, !synopsis.isEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .rating:
				let ratingSection = Layouts.ratingSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = ratingSection
				hasSectionHeader = true
			case .reviews: break
			case .information:
				let gridSection = Layouts.gridSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = gridSection
				hasSectionHeader = true
			case .cast:
				if !self.castIdentities.isEmpty {
					sectionLayout = Layouts.castSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .moreByStudio:
				if !self.studioLiteratureIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .sosumi:
				if let copyrightIsEmpty = self.literature.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasBackgroundDecoration = true
				}
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
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

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.65))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

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
}
