//
//  PersonDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension PersonDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 1

		switch self.snapshot.sectionIdentifiers[section] {
		case .header, .about:
			return 1
		case .rating:
			let columnCount = (width / 250).rounded().int
			return columnCount >= 3 ? 3 : 2
		case .rateAndReview:
			if UIDevice.isPhone {
				return 1
			}
			return width > 414 ? 2 : 1
		case .reviews:
			columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
		case .information:
			columnCount = width >= 414 ? (width / 200).rounded().int : (width / 160).rounded().int
			return columnCount > 0 ? columnCount : 2
		case .shows, .literatures, .games:
			columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			if columnCount > 5 {
				return 5
			}
		case .characters:
			columnCount = (width / 140.0).rounded().int
		}

		return columnCount > 0 ? columnCount : 1
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch self.snapshot.sectionIdentifiers[section] {
		case .header:
			return .estimated(230)
		case .about:
			return .estimated(20)
		case .rating:
			return .absolute(88)
		case .information:
			return .estimated(55)
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
			guard self.person != nil else { return nil }
			let personDetailSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch personDetailSection {
			case .header:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .about:
				if let about = self.person.attributes.about, !about.isEmpty {
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
			case .characters:
				if !self.characterIdentities.isEmpty {
					sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
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
