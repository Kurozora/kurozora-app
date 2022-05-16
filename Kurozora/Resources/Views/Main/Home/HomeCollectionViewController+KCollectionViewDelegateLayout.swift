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
				columnCount = (width / 562).rounded().int
			} else {
				columnCount = (width / 374).rounded().int
			}
		case .small:
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		case .medium:
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		case .large:
			if width >= 414 {
				columnCount = (width / 500).rounded().int
			} else {
				columnCount = (width / 324).rounded().int
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
		case .music:
			columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
		case .profile:
			columnCount = UIDevice.isPhone ? (width / 200).rounded().int : (width / 300).rounded().int
		case .quickLinks:
			let actionLinksCount = (width / 414).rounded().int
			columnCount = actionLinksCount > 5 ? 5 : actionLinksCount
		case .quickActions:
			let actionButtonCount = (width / 414).rounded().int
			columnCount = actionButtonCount > 2 ? 2 : actionButtonCount
		case .legal:
			columnCount = 1
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategorySection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: exploreCategorySection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil

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
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
			sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			return sectionLayout
		}
	}
}
