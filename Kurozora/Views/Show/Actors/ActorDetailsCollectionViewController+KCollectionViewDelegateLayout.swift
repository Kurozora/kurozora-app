//
//  ActorDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension ActorDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch ActorSection(rawValue: section) {
		case .main, .about:
			return 1
		case .shows:
			let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
			return columnCount > 0 ? columnCount : 1
		case .characters:
			let columnCount = (width / 200).rounded().int
			return columnCount > 0 ? columnCount : 1
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch ActorSection(rawValue: section) {
		case .main:
			return .estimated(230)
		case .about:
			return .estimated(20)
		case .information:
			return .estimated(55)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch ActorSection(rawValue: section) {
		case .main:
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		case .information:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self, self.actor != nil else { return nil }
			guard let actorSection = ActorSection(rawValue: section) else { fatalError("actor details section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch actorSection {
			case .main:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .about:
				if let about = self.actor.attributes.about, !about.isEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .information:
				let listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = listSection
				hasSectionHeader = true
			case .shows:
				if self.shows.count != 0 {
					let showsSectionLayout = self.showsSectionLayout(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = showsSectionLayout
					hasSectionHeader = true
				}
			case .characters:
				if self.characters.count != 0 {
					let charactersSectionLayout = self.charactersSectionLayout(section, layoutEnvironment: layoutEnvironment)
					sectionLayout = charactersSectionLayout
					hasSectionHeader = true
				}
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
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

	func charactersSectionLayout(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .estimated(50.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .estimated(50.0))
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

	func showsSectionLayout(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
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
}
