//
//  HomeCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension HomeCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .banner:
			if width >= 414 {
				columnCount = Int((width / 562).rounded())
			} else {
				columnCount = Int((width / 374).rounded())
			}
		case .small:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .medium:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .large:
			if width >= 414 {
				columnCount = Int((width / 500).rounded())
			} else {
				columnCount = Int((width / 324).rounded())
			}
		case .upcoming:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .video:
			if width >= 414 {
				columnCount = Int((width / 500).rounded())
			} else {
				columnCount = Int((width / 360).rounded())
			}
		case .episode:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .music:
			columnCount = Int((width / 250.0).rounded())
		case .profile:
			columnCount = Int((width / 140.0).rounded())
		case .quickLinks:
			columnCount = Int((width / 414).rounded())
		case .quickActions:
			columnCount = Int((width / 414).rounded())
		case .legal:
			columnCount = 1
		}

		switch section {
		case .banner, .small, .medium, .large, .video, .upcoming, .quickLinks:
			// Limit columns to 5 or less
			if columnCount > 5 {
				columnCount = 5
			}
		case .quickActions:
			// Limit columns to 2 or less
			if columnCount >= 2 {
				columnCount = self.quickActions.count == 1 ? 1 : 2
			}
		default: break
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategorySection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: exploreCategorySection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection?

			switch exploreCategorySection {
			case .banner:
				sectionLayout = Layouts.bannerSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				return sectionLayout
			case .large:
				sectionLayout = Layouts.largeSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .medium:
				sectionLayout = Layouts.mediumSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .small:
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .video:
				sectionLayout = Layouts.videoSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .upcoming:
				sectionLayout = Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .episode:
				sectionLayout = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .music:
				sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .profile:
				sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .quickLinks:
				sectionLayout = Layouts.quickLinkSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .quickActions:
				sectionLayout = Layouts.quickActionSection(section, columns: columns, layoutEnvironment: layoutEnvironment, collectionView: self.collectionView)
				return sectionLayout
			case .legal:
				sectionLayout = Layouts.legalSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				return sectionLayout
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
			)
			sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			return sectionLayout
		}
	}
}
