//
//  HomeCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension HomeCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .banner:
			if width >= 414 {
				columnCount = Int((width / 562).rounded())
			} else {
				columnCount = Int((width / 374).rounded())
			}
		case .small:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .medium:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .large:
			if width >= 414 {
				columnCount = Int((width / 500).rounded())
			} else {
				columnCount = Int((width / 324).rounded())
			}
		case .upcoming:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .video:
			if width >= 414 {
				columnCount = Int((width / 500).rounded())
			} else {
				columnCount = Int((width / 360).rounded())
			}
		case .episode:
			if width >= 414 {
				columnCount = Int((width / 384).rounded())
			} else {
				columnCount = Int((width / 284).rounded())
			}
		case .music:
			columnCount = Int((width / 250.0).rounded())
		case .profile:
			columnCount = Int((width / 140.0).rounded())
		case .quickLinks:
			columnCount = Int((width / 414).rounded())
		case .quickActions:
			columnCount = Int((width / 414).rounded())
		case .legal:
			columnCount = 1
		}

		switch section {
		case .banner, .small, .medium, .large, .video, .upcoming, .quickLinks:
			// Limit columns to 5 or less
			if columnCount > 5 {
				columnCount = 5
			}
		case .quickActions:
			// Limit columns to 2 or less
			if columnCount >= 2 {
				columnCount = self.quickActions.count == 1 ? 1 : 2
			}
		default: break
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let exploreCategorySection = self.snapshot.sectionIdentifiers[section]
			let columns = self.columnCount(forSection: exploreCategorySection, layout: layoutEnvironment)
			var sectionLayout: NSCollectionLayoutSection?

			switch exploreCategorySection {
			case .banner:
				sectionLayout = Layouts.bannerSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { _, show in
						BannerLockupCollectionViewCell.measurableItem(for: show)
					}
				}
				return sectionLayout
			case .large:
				sectionLayout = Layouts.largeSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { _, show in
						LargeLockupCollectionViewCell.measurableItem(for: show)
					}
				}
			case .medium:
				sectionLayout = Layouts.mediumSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(for: self.mediumMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
				}
			case .small:
				sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(for: self.smallMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
				}
			case .video:
				sectionLayout = Layouts.videoSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { _, show in
						VideoLockupCollectionViewCell.measurableItem(for: show)
					}
				}
			case .upcoming:
				sectionLayout = Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { _, show in
						UpcomingLockupCollectionViewCell.measurableItem(for: show)
					}
				}
			case .episode:
				sectionLayout = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { _, episode in
						EpisodeLockupCollectionViewCell.measurableItem(for: episode)
					}
				}
			case .music:
				sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					let showSongs = (self.exploreCategories[safe: section]?.relationships.showSongs?.data ?? []).prefix(Self.exploreCategoryItemLimit)
					let measurableItems = showSongs.map { MusicLockupCollectionViewCell.measurableItem(for: $0, showEpisodes: false, showShow: true) }

					return self.maximumCellHeight(for: measurableItems, width: width, layoutEnvironment: layoutEnvironment)
				}
			case .profile:
				sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
					self.maximumCellHeight(for: self.profileMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
				}
			case .quickLinks:
				sectionLayout = Layouts.quickLinkSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				sectionLayout?.visibleItemsInvalidationHandler = { [weak self] visibleItems, _, _ in
					guard let self = self else { return }
					let totalCount = self.quickLinks.count
					guard totalCount > 1 else { return }
					let columns = self.collectionView.columnCount(inSection: section)

					for item in visibleItems {
						guard let cell = self.collectionView.cellForItem(at: item.indexPath) as? ActionLinkExploreCollectionViewCell else { continue }
						cell.separatorView?.isHidden = item.indexPath.item + columns >= totalCount
					}
				}
			case .quickActions:
				sectionLayout = Layouts.quickActionSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				return sectionLayout
			case .legal:
				sectionLayout = Layouts.legalSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
				return sectionLayout
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
			)
			sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			return sectionLayout
		}
	}
}

// MARK: - Measurement
extension HomeCollectionViewController {
	/// Returns the items that measure the cells of a small section.
	///
	/// - Parameter section: The section to measure.
	///
	/// - Returns: The items that measure the section's cells.
	func smallMeasurableItems(inSection section: Int) -> [CellHeightMeasurer.Item] {
		let recaps = self.exploreCategories[safe: section]?.relationships.recaps?.data ?? []
		var measurableItems = recaps.prefix(Self.exploreCategoryItemLimit).map { RecapPosterLockupCollectionViewCell.measurableItem(for: $0) }

		measurableItems += self.cachedItems(inSection: section).compactMap { item in
			switch item {
			case let show as Show:
				return SmallLockupCollectionViewCell.measurableItem(for: show)
			case let literature as Literature:
				return SmallLockupCollectionViewCell.measurableItem(for: literature)
			case let game as Game:
				return GameLockupCollectionViewCell.measurableItem(for: game)
			case let episode as Episode:
				return EpisodeLockupCollectionViewCell.measurableItem(for: episode)
			default:
				return nil
			}
		}

		return measurableItems
	}

	/// Returns the items that measure the cells of a medium section.
	///
	/// - Parameter section: The section to measure.
	///
	/// - Returns: The items that measure the section's cells.
	func mediumMeasurableItems(inSection section: Int) -> [CellHeightMeasurer.Item] {
		return self.cachedItems(inSection: section).compactMap { item in
			switch item {
			case let genre as Genre:
				return MediumLockupCollectionViewCell.measurableItem(for: genre)
			case let theme as Theme:
				return MediumLockupCollectionViewCell.measurableItem(for: theme)
			default:
				return nil
			}
		}
	}

	/// Returns the items that measure the cells of a profile section.
	///
	/// - Parameter section: The section to measure.
	///
	/// - Returns: The items that measure the section's cells.
	func profileMeasurableItems(inSection section: Int) -> [CellHeightMeasurer.Item] {
		return self.cachedItems(inSection: section).compactMap { item in
			switch item {
			case let character as Character:
				return ProfileLockupCollectionViewCell.measurableItem(for: character)
			case let person as Person:
				return ProfileLockupCollectionViewCell.measurableItem(for: person)
			default:
				return nil
			}
		}
	}
}
