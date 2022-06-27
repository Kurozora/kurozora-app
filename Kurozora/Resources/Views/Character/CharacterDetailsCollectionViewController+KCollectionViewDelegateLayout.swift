//
//  CharacterDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension CharacterDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch self.snapshot.sectionIdentifiers[section] {
		case .header, .about:
			return 1
		case .shows:
			let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			return columnCount > 0 ? columnCount : 1
		case .people:
			let columnCount = (width / 140.0).rounded().int
			return columnCount > 0 ? columnCount : 1
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch self.snapshot.sectionIdentifiers[section] {
		case .header:
			return .estimated(230)
		case .about:
			return .estimated(20)
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
			guard self.character != nil else { return nil }
			let characterDetailSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch characterDetailSection {
			case .header:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .about:
				if let about = self.character.attributes.about, !about.isEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .information:
				let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = gridSection
				hasSectionHeader = true
			case .people:
				if self.personIdentities.count != 0 {
					sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					hasSectionHeader = true
				}
			case .shows:
				if self.showIdentities.count != 0 {
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
