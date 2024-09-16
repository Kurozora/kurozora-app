//
//  StudioDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension StudioDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch self.snapshot.sectionIdentifiers[section] {
		case .header, .about:
			return 1
		case .badges:
			return width > 414 ? StudioDetail.Badge.allCases.count : (width / 132).rounded().int
		case .shows, .literatures, .games:
			let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			return columnCount > 0 ? columnCount : 1
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch self.snapshot.sectionIdentifiers[section] {
		case .header:
			return .fractionalHeight(1.0)
		case .badges:
			return .estimated(50)
		case .about:
			return .estimated(100)
		case .information:
			return .fractionalHeight(1.0)
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
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard self.studio != nil else { return nil }
			let studioDetailSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch studioDetailSection {
			case .header:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .badges:
				let badgeSection = Layouts.badgeSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = badgeSection
			case .about:
				if let about = self.studio.attributes.about, !about.isEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .information:
				let gridSection = Layouts.gridSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = gridSection
				hasSectionHeader = true
			case .shows:
				if !self.showIdentities.isEmpty {
					let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
					let smallSectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = smallSectionLayout
					hasSectionHeader = true
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
					let smallSectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = smallSectionLayout
					hasSectionHeader = true
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
					let smallSectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = smallSectionLayout
					hasSectionHeader = true
				}
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			return sectionLayout
		}
		return layout
	}
}
