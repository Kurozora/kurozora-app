//
//  GameDetailsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension GameDetailsCollectionViewController {
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
		case .header, .countdown, .synopsis, .sosumi:
			return 1
		case .badge:
			return width > 414 ? GameDetail.Badge.allCases.count : Int((width / 132).rounded())
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
		case .cast:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
			if columnCount > 5 {
				return 5
			}
		case .studios:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
			if columnCount > 5 {
				return 5
			}
		case .moreByStudio, .relatedGames, .relatedShows, .relatedLiteratures:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
			if columnCount > 5 {
				return 5
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch self.snapshot.sectionIdentifiers[section] {
		case .header:
			return .fractionalHeight(1.0)
		case .badge:
			return .estimated(50)
		case .countdown:
			return .estimated(88)
		case .synopsis:
			return .estimated(100)
		case .rating:
			return .absolute(88)
		case .information:
			return .fractionalHeight(1.0)
		case .sosumi:
			return .estimated(50)
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
		case .sosumi:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard self.game != nil || self.libraryEntry != nil else { return nil }
			let gameDetailSection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection?
			var hasSectionHeader = false
			var hasBackgroundDecoration = false

			switch gameDetailSection {
			case .header:
				let headerSection = Layouts.headerSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let badgeSection = Layouts.badgeSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = badgeSection
			case .countdown:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .synopsis:
				if let synopsis = self.game.attributes.synopsis, !synopsis.isEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .rating:
				let ratingSection = Layouts.ratingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, itemCount: self.snapshot.numberOfItems(inSection: .rating))
				sectionLayout = ratingSection
				hasSectionHeader = true
			case .rateAndReview:
				let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
				hasSectionHeader = true
			case .reviews:
				if !self.reviews.isEmpty || self.editorial != nil {
					sectionLayout = Layouts.reviewsSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
				}
			case .information:
				let gridSection = Layouts.gridSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout = gridSection
				hasSectionHeader = true
			case .cast:
				if !self.castIdentities.isEmpty {
					sectionLayout = Layouts.castSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
					hasSectionHeader = true
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
					hasSectionHeader = true
				}
			case .moreByStudio:
				if !self.studioGameIdentities.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { _ in
						self.cellHeight(for: gameDetailSection)
					}
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .sosumi:
				if let copyrightIsEmpty = self.game.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					let fullSection = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
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
				let isLastSection = section == self.snapshot.sectionIdentifiers.count - 1
				sectionLayout?.decorationItems = [Layouts.backgroundDecoration(extendsToBottom: isLastSection, layoutEnvironment: layoutEnvironment)]
			}

			return sectionLayout
		}
		layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		return layout
	}
}
