//
//  TopChartsCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension TopChartsCollectionViewController {
	func columnCount(forSection section: SectionLayoutKind, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0

		switch section {
		case .chart(let chartKind):
			switch chartKind {
			case .shows, .literatures, .games, .episodes, .studios:
				if width >= 414 {
					columnCount = Int((width / 384).rounded())
				} else {
					columnCount = Int((width / 284).rounded())
				}
			case .characters, .people:
				columnCount = Int((width / 140.0).rounded())
			case .songs:
				columnCount = Int((width / 250.0).rounded())
			}

			switch chartKind {
			case .shows, .literatures, .games:
				// Limit columns to 5 or less
				if columnCount > 5 {
					columnCount = 5
				}
			default: break
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard let snapshot = self.snapshot, let chartSection = snapshot.sectionIdentifiers[safe: section] else { return nil }
			let columns = self.columnCount(forSection: chartSection, layout: layoutEnvironment)
			let sectionLayout: NSCollectionLayoutSection

			switch chartSection {
			case .chart(let chartKind):
				switch chartKind {
				case .shows, .literatures, .games:
					sectionLayout = Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
						self.maximumCellHeight(for: self.chartMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
					}
				case .characters:
					sectionLayout = Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
						self.maximumCellHeight(for: self.chartMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
					}
				case .people:
					sectionLayout = Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
						self.maximumCellHeight(for: self.chartMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
					}
				case .episodes:
					sectionLayout = Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
						self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { item, episode in
							EpisodeLockupCollectionViewCell.measurableItem(for: episode, rank: item + 1)
						}
					}
				case .songs:
					sectionLayout = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
						self.maximumCellHeight(inSection: section, width: width, layoutEnvironment: layoutEnvironment) { item, song in
							MusicLockupCollectionViewCell.measurableItem(for: song, rank: item + 1)
						}
					}
				case .studios:
					sectionLayout = Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment) { width in
						self.maximumCellHeight(for: self.chartMeasurableItems(inSection: section), width: width, layoutEnvironment: layoutEnvironment)
					}
				}
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
			)
			sectionLayout.boundarySupplementaryItems = [sectionHeader]
			return sectionLayout
		}
	}
}

// MARK: - Measurement
extension TopChartsCollectionViewController {
	/// Returns the items that measure the cells of a ranked chart section.
	///
	/// - Parameter section: The section to measure.
	///
	/// - Returns: The items that measure the section's cells.
	func chartMeasurableItems(inSection section: Int) -> [CellHeightMeasurer.Item] {
		return self.cachedItems(inSection: section).compactMap { item, model in
			let rank = item + 1

			switch model {
			case let show as Show:
				return SmallLockupCollectionViewCell.measurableItem(for: show, rank: rank)
			case let literature as Literature:
				return SmallLockupCollectionViewCell.measurableItem(for: literature, rank: rank)
			case let game as Game:
				return GameLockupCollectionViewCell.measurableItem(for: game, rank: rank)
			case let character as Character:
				return ProfileLockupCollectionViewCell.measurableItem(for: character, rank: rank)
			case let person as Person:
				return ProfileLockupCollectionViewCell.measurableItem(for: person, rank: rank)
			case let studio as Studio:
				return StudioLockupCollectionViewCell.measurableItem(for: studio, rank: rank)
			default:
				return nil
			}
		}
	}
}
