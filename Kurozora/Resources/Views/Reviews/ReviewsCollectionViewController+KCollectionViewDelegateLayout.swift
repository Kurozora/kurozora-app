//
//  ReviewsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension ReviewsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 1

		switch self.snapshot.sectionIdentifiers[section] {
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
		}

		return columnCount > 0 ? columnCount : 1
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch self.snapshot.sectionIdentifiers[section] {
		case .rating:
			return .absolute(88)
		default:
			return .fractionalWidth(.zero)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch self.snapshot.sectionIdentifiers[section] {
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }

			let reviewSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection? = nil

			switch reviewSection {
			case .rating:
				let ratingSection = Layouts.ratingSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = ratingSection
			case .rateAndReview:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .reviews:
				if !self.reviews.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
				}
			}

			return sectionLayout
		}
		return layout
	}
}
