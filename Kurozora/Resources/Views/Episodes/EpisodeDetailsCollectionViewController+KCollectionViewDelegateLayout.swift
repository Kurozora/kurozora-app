//
//  EpisodeDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension EpisodeDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 1

		switch self.snapshot.sectionIdentifiers[section] {
		case .header, .synopsis, .sosumi:
			return 1
		case .badge:
			return width > 414 ? GameDetail.Badge.allCases.count : Int((width / 132).rounded())
		case .rating:
			let columnCount = Int((width / 250).rounded())
			return columnCount >= 3 ? 3 : 2
		case .rateAndReview:
			if UIDevice.isPhone {
				return 1
			}
			return width > 414 ? 2 : 1
		case .reviews:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		case .information:
			columnCount = Int(width >= 414 ? (width / 200).rounded() : (width / 160).rounded())
			return columnCount > 0 ? columnCount : 2
		case .cast:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
			if columnCount > 5 {
				return 5
			}
		case .suggestedEpisodes:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())

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
		default:
			return .fractionalWidth(.zero)
		}
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
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
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard self.episode != nil else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch self.snapshot.sectionIdentifiers[section] {
			case .header:
				let headerSection = self.headerSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let badgeSection = Layouts.badgeSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = badgeSection
			case .synopsis:
				if let synopsis = self.episode.attributes.synopsis, !synopsis.isEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .rating:
				let ratingSection = Layouts.ratingSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = ratingSection
				hasSectionHeader = true
			case .rateAndReview:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
				hasSectionHeader = true
			case .reviews:
				if !self.reviews.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				}
			case .information:
				let gridSection = Layouts.gridSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = gridSection
				hasSectionHeader = true
			case .cast:
				if !self.castIdentities.isEmpty {
					sectionLayout = Layouts.castSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .suggestedEpisodes:
				if !self.suggestedEpisodes.isEmpty {
					let episodeSection = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
					sectionLayout = episodeSection
					hasSectionHeader = true
				}
			case .sosumi: break
//				if let copyrightIsEmpty = self.episode.attributes.copyright?.isEmpty, !copyrightIsEmpty {
//					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
//					sectionLayout = fullSection
//					hasBackgroundDecoration = true
//				}
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
				)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			return sectionLayout
		}
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
}
