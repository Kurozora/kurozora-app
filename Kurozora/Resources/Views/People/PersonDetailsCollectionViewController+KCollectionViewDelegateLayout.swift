//
//  PersonDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension PersonDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		guard let sectionIdentifier = self.snapshot?.sectionIdentifiers[safe: section] else { return 1 }

		return self.columnCount(forSection: sectionIdentifier, width: layoutEnvironment.container.effectiveContentSize.width)
	}

	/// Returns the number of items the given section lays out in a row.
	///
	/// - Parameters:
	///    - section: The section to lay out.
	///    - width: The width available to the collection view's content.
	///
	/// - Returns: The number of columns.
	func columnCount(forSection section: SectionLayoutKind, width: CGFloat) -> Int {
		var columnCount = 1

		switch section {
		case .header, .about:
			return 1
		case .rating:
			let columnCount = Int((width / 250).rounded())
			return columnCount >= 3 ? 3 : 2
		case .rateAndReview:
			if UIDevice.isPhone {
				return 1
			}
			return width > 414 ? 2 : 1
		case .reviews:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		case .information:
			columnCount = Int(width >= 414 ? (width / 200).rounded(.down) : (width / 160).rounded(.down))
			return columnCount > 0 ? columnCount : 1
		case .shows, .literatures, .games, .relationships:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
			if columnCount > 5 {
				return 5
			}
		case .characters:
			columnCount = Int((width / 140.0).rounded())
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
			guard self.person != nil else { return nil }
			let personDetailSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection?
			var hasSectionHeader = false
			var hasBackgroundDecoration = false

			switch personDetailSection {
			case .header:
				let headerSection = Layouts.profileHeaderSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .about:
				if let about = self.person.attributes.about, !about.isEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .rating:
				let ratingSection = Layouts.ratingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, itemCount: PersonDetail.Rating.allCases.count)
				sectionLayout = ratingSection
				hasSectionHeader = true
			case .rateAndReview:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
				hasSectionHeader = true
			case .reviews:
				if !self.reviews.isEmpty {
					sectionLayout = Layouts.reviewsSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: personDetailSection))
				}
			case .information:
				let gridSection = Layouts.gridSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = gridSection
				hasSectionHeader = true
			case .characters:
				if !self.characterIdentities.isEmpty {
					sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: personDetailSection))
					hasSectionHeader = true
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: personDetailSection))
					hasSectionHeader = true
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: personDetailSection))
					hasSectionHeader = true
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: personDetailSection))
					hasSectionHeader = true
				}
			case .relationships:
				if !self.relationships.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, maximumHeight: self.cellHeight(for: personDetailSection))
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
				)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			if hasBackgroundDecoration {
				let isLastSection = section == self.laidOutSectionCount - 1
				sectionLayout?.decorationItems = [Layouts.backgroundDecoration(extendsToBottom: isLastSection, layoutEnvironment: layoutEnvironment)]
			}

			return sectionLayout
		}
		layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		return layout
	}
}
