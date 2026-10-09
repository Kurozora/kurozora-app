//
//  DigestCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension DigestCollectionViewController {
	/// Returns the number of items the given section lays out in a row.
	///
	/// - Parameters:
	///    - section: The section to lay out.
	///    - width: The width available to the collection view's content.
	///
	/// - Returns: The number of columns.
	func columnCount(forSection section: SectionLayoutKind, width: CGFloat) -> Int {
		switch section {
		case .hero, .momentum, .growth:
			return 1
		case .birthdays:
			let columnCount = Int((width / 140.0).rounded())
			return columnCount > 0 ? columnCount : 1
		default:
			var columnCount = if width >= 414 {
				Int((width / 384).rounded())
			} else {
				Int((width / 284).rounded())
			}

			// Limit columns to 5 or less.
			if columnCount > 5 {
				columnCount = 5
			}

			return columnCount > 0 ? columnCount : 1
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let digestSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: digestSection, width: layoutEnvironment.container.effectiveContentSize.width)
			let sectionLayout: NSCollectionLayoutSection?

			switch digestSection {
			case .hero:
				sectionLayout = self.heroSectionLayout(layoutEnvironment)
			case .newReleases, .becauseYouWatched, .dropIn, .rescueOnHold, .rescuePlanning, .premiering, .releasing:
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: digestSection))
			case .newEpisodes, .finales, .trending:
				sectionLayout = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: digestSection))
			case .birthdays:
				sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: digestSection))
			case .momentum, .growth:
				sectionLayout = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			}

			if self.hasHeader(for: digestSection) {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
				)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			// The momentum band spans edge to edge, under the safe area; every other section keeps the readable margins.
			if digestSection == .momentum {
				sectionLayout?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
				sectionLayout?.contentInsetsReference = .none
			} else {
				sectionLayout?.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			}
			return sectionLayout
		}
	}

	/// The full-width layout for the hero — a banner with its caption stacked beneath it.
	private func heroSectionLayout(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let bannerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(230.0)))
		let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(24.0)))

		let layoutGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(254.0)),
			subitems: [bannerItem, captionItem]
		)
		layoutGroup.interItemSpacing = .fixed(8.0)

		return NSCollectionLayoutSection(group: layoutGroup)
	}
}
