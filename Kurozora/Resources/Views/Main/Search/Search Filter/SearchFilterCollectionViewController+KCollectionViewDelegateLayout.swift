//
//  SearchFilterCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SearchFilterCollectionViewController {
	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }

			let pillDescriptors = self.descriptors.filter { !$0.control.isRow }
			let layoutSection: NSCollectionLayoutSection

			switch pillDescriptors[safe: section]?.control {
			case .duration:
				layoutSection = self.durationSection(layoutEnvironment: layoutEnvironment)
			case .numberPills, .textPills, .booleanPills:
				layoutSection = Layouts.fullSection(section, columns: 2, layoutEnvironment: layoutEnvironment)
			default:
				layoutSection = self.detailsSection(layoutEnvironment: layoutEnvironment)
			}

			layoutSection.boundarySupplementaryItems = [self.sectionHeader()]
			return layoutSection
		}
	}

	/// The section holding a row of clocks.
	///
	/// - Parameter layoutEnvironment: The environment the section is laid out in.
	///
	/// - Returns: The section the clocks sit in.
	private func durationSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(96.0), heightDimension: .absolute(96.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(96.0), heightDimension: .absolute(96.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.orthogonalScrollingBehavior = .continuous
		layoutSection.interGroupSpacing = 12.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(
			top: 0,
			leading: self.collectionView.directionalLayoutMargins.leading,
			bottom: 20.0,
			trailing: self.collectionView.directionalLayoutMargins.trailing
		)
		return layoutSection
	}

	/// The section holding the card of rows.
	///
	/// - Parameter layoutEnvironment: The environment the section is laid out in.
	///
	/// - Returns: The section the rows sit in.
	private func detailsSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(
			top: 0,
			leading: self.collectionView.directionalLayoutMargins.leading,
			bottom: 20.0,
			trailing: self.collectionView.directionalLayoutMargins.trailing
		)
		return layoutSection
	}

	/// The header shown above a filter.
	///
	/// - Returns: The header the section shows.
	private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))

		return NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .top
		)
	}
}
