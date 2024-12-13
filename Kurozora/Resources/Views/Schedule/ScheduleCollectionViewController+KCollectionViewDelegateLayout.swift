//
//  ScheduleCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ScheduleCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .schedule:
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		}

		switch section {
		case .schedule:
			// Limit columns to 5 or less
			if columnCount > 5 {
				columnCount = 5
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch self.snapshot.sectionIdentifiers[section] {
		case .schedule:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategorySection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: exploreCategorySection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil
			let hasBackgroundDecoration: Bool

			switch exploreCategorySection {
			case .schedule(let schedule):
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
				hasBackgroundDecoration = schedule.attributes.date.isInToday
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
			sectionLayout?.boundarySupplementaryItems = [sectionHeader]

			// Add background decoration view.
			if hasBackgroundDecoration {
				let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.elementKindSectionBackground)
				sectionLayout?.decorationItems = [sectionBackgroundDecoration]
			}

			sectionLayout?.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return sectionLayout
		}
		layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		return layout
	}
}
