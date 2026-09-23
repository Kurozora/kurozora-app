//
//  ReCapCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReCapCollectionViewController {
	/// The space between a section and the page's edges.
	private static let horizontalInset: CGFloat = 10.0

	/// The space between two columns or cards in a row.
	private static let interGroupSpacing: CGFloat = 16.0

	/// The narrowest a card may be.
	private static let minimumCardWidth: CGFloat = 256.0

	/// The widest a card may be.
	private static let maximumCardWidth: CGFloat = 384.0

	/// The fraction of the row a card takes when the next card peeks in.
	private static let peekingWidthFraction: CGFloat = 0.9

	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .header, .topGenres, .topThemes, .stats, .comparisons, .milestones, .keepTracking:
			return 1
		case .topShows, .topGames, .topLiteratures, .topStudios, .topByMonth:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}

			columnCount = min(columnCount, 5)
		case .topCharacters, .topVoices, .topCreators:
			columnCount = Int((width / 240.0).rounded())
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let width = collectionViewLayout.container.effectiveContentSize.width

		switch self.snapshot.sectionIdentifiers[section] {
		case .header:
			return .zero
		case .milestones(false):
			return NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: 8.0, trailing: Self.horizontalInset)
		default:
			let bottom: CGFloat = width >= 414 ? 144.0 : 40.0
			return NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottom, trailing: Self.horizontalInset)
		}
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let sectionKind = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: sectionKind, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection?
			var hasSectionHeader = true

			switch sectionKind {
			case .header:
				sectionLayout = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				hasSectionHeader = false
			case .keepTracking:
				sectionLayout = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				hasSectionHeader = false
			case .topShows, .topGames, .topLiteratures, .topByMonth:
				sectionLayout = self.columnsSection(inSection: section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .topGenres, .topThemes:
				sectionLayout = Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
			case .topStudios:
				sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(for: self.recapMeasurableItems(inSection: section), inSection: section, width: width, layoutEnvironment: layoutEnvironment)
				}
			case .topCharacters, .topVoices, .topCreators:
				sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(for: self.recapMeasurableItems(inSection: section), inSection: section, width: width, layoutEnvironment: layoutEnvironment)
				}
			case .stats, .comparisons:
				sectionLayout = self.cardsSection(inSection: section, layoutEnvironment: layoutEnvironment)
			case .milestones(let isFullSection):
				sectionLayout = self.cardsSection(inSection: section, isFullWidth: isFullSection, layoutEnvironment: layoutEnvironment)
				hasSectionHeader = false
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
				)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			var contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)

			switch sectionKind {
			case .stats, .comparisons, .milestones(false):
				contentInsets.trailing = self.pagingTrailingInset(inSection: section, insets: contentInsets, layoutEnvironment: layoutEnvironment)
			default:
				break
			}

			sectionLayout?.contentInsets = contentInsets
			return sectionLayout
		}
	}

	/// Returns a row of columns stacking two titles each.
	///
	/// - Parameters:
	///    - section: The index of the section.
	///    - columns: The number of columns shown at once.
	///    - layoutEnvironment: The environment the section is laid out in.
	///
	/// - Returns: The section layout.
	private func columnsSection(inSection section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width - Self.horizontalInset * 2.0
		let columnCount = CGFloat(columns)
		let columnWidth = ((containerWidth * 0.98) - Self.interGroupSpacing * (columnCount - 1.0)) / columnCount
		let itemHeight = self.maximumCellHeight(for: self.recapMeasurableItems(inSection: section), inSection: section, width: columnWidth, layoutEnvironment: layoutEnvironment) ?? 150.0
		let separatorHeight = ReCapTitleLockupCollectionViewCell.separatorHeight
		let rowCount = min(self.itemKinds(inSection: section).count, 2)

		let upperItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight)))
		let lowerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight + separatorHeight)))
		let subitems = rowCount > 1 ? [upperItem, lowerItem] : [upperItem]
		let columnHeight = rowCount > 1 ? itemHeight * 2.0 + separatorHeight : itemHeight

		let columnSize = NSCollectionLayoutSize(widthDimension: .absolute(columnWidth), heightDimension: .absolute(columnHeight))
		let columnGroup = NSCollectionLayoutGroup.vertical(layoutSize: columnSize, subitems: subitems)

		let layoutSection = NSCollectionLayoutSection(group: columnGroup)
		layoutSection.interGroupSpacing = Self.interGroupSpacing
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		return layoutSection
	}

	/// Returns the width of a card in the given section.
	///
	/// - Parameters:
	///    - section: The index of the section.
	///    - isFullWidth: Whether a single card spans the whole row.
	///    - layoutEnvironment: The environment the section is laid out in.
	///
	/// - Returns: The width of a card.
	private func cardWidth(inSection section: Int, isFullWidth: Bool, layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width - Self.horizontalInset * 2.0
		guard !isFullWidth else { return containerWidth }

		let rowWidth = self.itemKinds(inSection: section).count > 1 ? layoutEnvironment.container.effectiveContentSize.width * Self.peekingWidthFraction : containerWidth
		return min(max(rowWidth, Self.minimumCardWidth), Self.maximumCardWidth)
	}

	/// Returns the trailing inset that lets the last card of a paging row rest at the leading edge.
	///
	/// - Parameters:
	///    - section: The index of the section.
	///    - insets: The insets of the section.
	///    - layoutEnvironment: The environment the section is laid out in.
	///
	/// - Returns: The trailing inset of the section.
	private func pagingTrailingInset(inSection section: Int, insets: NSDirectionalEdgeInsets, layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		guard self.itemKinds(inSection: section).count > 1 else { return insets.trailing }

		let cardWidth = self.cardWidth(inSection: section, isFullWidth: false, layoutEnvironment: layoutEnvironment)
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		return max(containerWidth - insets.leading - cardWidth, insets.trailing)
	}

	/// Returns a row of equally tall cards.
	///
	/// - Parameters:
	///    - section: The index of the section.
	///    - isFullWidth: Whether a single card spans the whole row.
	///    - layoutEnvironment: The environment the section is laid out in.
	///
	/// - Returns: The section layout.
	private func cardsSection(inSection section: Int, isFullWidth: Bool = false, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let cardWidth = self.cardWidth(inSection: section, isFullWidth: isFullWidth, layoutEnvironment: layoutEnvironment)
		let height = self.maximumCellHeight(for: self.recapMeasurableItems(inSection: section), inSection: section, width: cardWidth, layoutEnvironment: layoutEnvironment)
		let heightDimension: NSCollectionLayoutDimension = height.map { .absolute($0) } ?? .estimated(200.0)

		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height == nil ? heightDimension : .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(cardWidth), heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = Self.interGroupSpacing

		guard !isFullWidth else { return layoutSection }

		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		return layoutSection
	}
}

extension ReCapCollectionViewController {
	/// Returns the items that measure the cells of a section.
	///
	/// - Parameter section: The section to measure.
	///
	/// - Returns: The items that measure the section's cells.
	func recapMeasurableItems(inSection section: Int) -> [CellHeightMeasurer.Item] {
		return self.itemKinds(inSection: section).enumerated().compactMap { index, itemKind in
			let rank = index + 1

			switch itemKind {
			case .showIdentity(_, let detail, _):
				guard let show = self.cache[itemKind] as? Show else { return nil }
				return CellHeightMeasurer.Item(cellType: ReCapTitleLockupCollectionViewCell.self) { cell in
					cell.configure(using: show, rank: rank, detail: detail, showsSeparator: false)
				}
			case .literatureIdentity(_, let detail, _):
				guard let literature = self.cache[itemKind] as? Literature else { return nil }
				return CellHeightMeasurer.Item(cellType: ReCapTitleLockupCollectionViewCell.self) { cell in
					cell.configure(using: literature, rank: rank, detail: detail, showsSeparator: false)
				}
			case .gameIdentity(_, let detail, _):
				guard let game = self.cache[itemKind] as? Game else { return nil }
				return CellHeightMeasurer.Item(cellType: ReCapTitleLockupCollectionViewCell.self) { cell in
					cell.configure(using: game, rank: rank, detail: detail, showsSeparator: false)
				}
			case .monthlyTitle(_, let month, _):
				let eyebrow = Month(rawValue: month)?.name
				switch self.cache[itemKind] {
				case let show as Show:
					return CellHeightMeasurer.Item(cellType: ReCapTitleLockupCollectionViewCell.self) { cell in
						cell.configure(using: show, rank: nil, eyebrow: eyebrow, detail: nil, showsSeparator: false)
					}
				case let literature as Literature:
					return CellHeightMeasurer.Item(cellType: ReCapTitleLockupCollectionViewCell.self) { cell in
						cell.configure(using: literature, rank: nil, eyebrow: eyebrow, detail: nil, showsSeparator: false)
					}
				case let game as Game:
					return CellHeightMeasurer.Item(cellType: ReCapTitleLockupCollectionViewCell.self) { cell in
						cell.configure(using: game, rank: nil, eyebrow: eyebrow, detail: nil, showsSeparator: false)
					}
				default:
					return nil
				}
			case .studioIdentity(_, let detail, _):
				guard let studio = self.cache[itemKind] as? Studio else { return nil }
				return StudioLockupCollectionViewCell.measurableItem(for: studio, rank: rank, detail: detail)
			case .characterIdentity:
				guard let character = self.cache[itemKind] as? Character else { return nil }
				return ProfileLockupCollectionViewCell.measurableItem(for: character, rank: rank)
			case .personIdentity(_, let detail, _):
				guard let person = self.cache[itemKind] as? Person else { return nil }
				return ProfileLockupCollectionViewCell.measurableItem(for: person, detail: detail, rank: rank)
			case .statCard(let statCard):
				return CellHeightMeasurer.Item(cellType: ReCapStatLockupCollectionViewCell.self) { cell in
					cell.configure(using: statCard)
				}
			case .comparison(let recapItemType):
				guard let comparison = self.comparisons[recapItemType] else { return nil }
				let colors = self.recapColors
				return CellHeightMeasurer.Item(cellType: ReCapComparisonLockupCollectionViewCell.self) { cell in
					cell.configure(using: comparison, colors: colors)
				}
			case .recapItem(let recapItem, let milestoneKind):
				let milestone = self.milestone(for: recapItem, milestoneKind: milestoneKind)
				return CellHeightMeasurer.Item(cellType: ReCapMilestoneCollectionViewCell.self) { cell in
					cell.configure(using: milestone)
				}
			default:
				return nil
			}
		}
	}
}
