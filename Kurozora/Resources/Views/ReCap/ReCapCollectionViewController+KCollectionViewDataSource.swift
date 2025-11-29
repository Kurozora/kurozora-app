//
//  ReCapCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReCapCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let headerCellConfiguration = self.getConfiguredHeaderCell()
		let gameCellConfiguration = self.getConfiguredGameCell()
		let mediumCellConfiguration = self.getConfiguredMediumCell()
		let smallCellConfiguration = self.getConfiguredSmallCell()
		let milestoneCellConfiguration = self.getConfiguredMilestoneCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let recapSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch recapSection {
			case .header:
				return collectionView.dequeueConfiguredReusableCell(using: headerCellConfiguration, for: indexPath, item: itemKind)
			case .topShows, .topLiteratures:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellConfiguration, for: indexPath, item: itemKind)
			case .topGames:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
			case .topGenres, .topThemes:
				return collectionView.dequeueConfiguredReusableCell(using: mediumCellConfiguration, for: indexPath, item: itemKind)
			case .milestones:
				return collectionView.dequeueConfiguredReusableCell(using: milestoneCellConfiguration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			let title: String?
			let subtitle: String?

			switch sectionLayoutKind {
			case .header:
				return nil
			case .topShows(let recap), .topGames(let recap), .topLiteratures(let recap):
				title = Trans.top(recap.attributes.type)
				subtitle = Trans.totalSeries("\(recap.attributes.totalSeriesCount)")
			case .topGenres(let recap), .topThemes(let recap):
				title = Trans.top(recap.attributes.type)
				subtitle = nil
			case .milestones:
				return nil
			}

			exploreSectionTitleCell.configure(withTitle: title, subtitle, segueID: "", separatorIsHidden: true)

			// Return the view.
			return exploreSectionTitleCell
		}
	}

	override func updateDataSource() {
		self.cache = [:]
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if self.recapItems.isEmpty {
			if self.year == Date.now.components.year, self.month == Date.now.components.month {
				let title: String

				if Date.now.components.month == 12 {
					title = "December Re:CAP is still in progress. Check back in a week."
				} else if let month = Month(rawValue: self.month) {
					title = "\(month.name) Re:CAP is still in progress. Check back in early \(month.next.name)."
				} else {
					title = "Re:CAP is still in progress. Check back early next month."
				}

				let header: SectionLayoutKind = .header(title)
				self.snapshot.appendSections([header])
				self.snapshot.appendItems([.string(title, section: .header(title))], toSection: header)
			}
		} else {
			if let month = Month(rawValue: self.month) {
				let title = "Series that defined your arc in \(month.name)"
				let sectionHeader = SectionLayoutKind.header(title)

				self.snapshot.appendSections([sectionHeader])
				self.snapshot.appendItems([.string(title, section: sectionHeader)], toSection: sectionHeader)
			}

			// Add Re:CAP categories
			self.recapItems.forEach { recapItem in
				var sectionHeader: SectionLayoutKind
				var itemKinds: [ItemKind] = []

				switch recapItem.attributes.recapItemType {
				case .shows:
					sectionHeader = .topShows(recapItem)
					if let shows = recapItem.relationships?.shows?.data {
						itemKinds = shows.map { showIdentity in
							return .showIdentity(showIdentity, section: sectionHeader)
						}
					}
				case .literatures:
					sectionHeader = .topLiteratures(recapItem)
					if let literature = recapItem.relationships?.literatures?.data {
						itemKinds = literature.map { literatureIdentity in
							return .literatureIdentity(literatureIdentity, section: sectionHeader)
						}
					}
				case .games:
					sectionHeader = .topGames(recapItem)
					if let games = recapItem.relationships?.games?.data {
						itemKinds = games.map { gameIdentity in
							return .gameIdentity(gameIdentity, section: sectionHeader)
						}
					}
				case .genres:
					sectionHeader = .topGenres(recapItem)
					if let genres = recapItem.relationships?.genres?.data {
						itemKinds = genres.map { genre in
							return .genreIdentity(genre, section: sectionHeader)
						}
					}
				case .themes:
					sectionHeader = .topThemes(recapItem)
					if let themes = recapItem.relationships?.themes?.data {
						itemKinds = themes.map { theme in
							return .themeIdentity(theme, section: sectionHeader)
						}
					}
				}

				self.snapshot.appendSections([sectionHeader])
				self.snapshot.appendItems(itemKinds, toSection: sectionHeader)
			}

			// Add milestones
			let title = "These milestones marked your season finale"
			let sectionHeader = SectionLayoutKind.header(title)

			self.snapshot.appendSections([sectionHeader])
			self.snapshot.appendItems([.string(title, section: sectionHeader)], toSection: sectionHeader)

			var milestoneItems: [ItemKind] = []
			self.recapItems.forEach { recapItem in
				switch recapItem.attributes.recapItemType {
				case .shows:
					if recapItem.attributes.totalPartsDuration > 0 {
						let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .minuetsWatched)
						milestoneItems.append(itemKind)
					}

					if recapItem.attributes.totalPartsCount > 0 {
						let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .episodesWatched)
						milestoneItems.append(itemKind)
					}
				case .literatures:
					if recapItem.attributes.totalPartsDuration > 0 {
						let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .minuetsRead)
						milestoneItems.append(itemKind)
					}

					if recapItem.attributes.totalPartsCount > 0 {
						let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .chaptersRead)
						milestoneItems.append(itemKind)
					}
				case .games:
					if recapItem.attributes.totalPartsDuration > 0 {
						let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .minutesPlayed)
						milestoneItems.append(itemKind)
					}

					if recapItem.attributes.totalPartsCount > 0 {
						let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .gamesPlayed)
						milestoneItems.append(itemKind)
					}
				case .genres, .themes: break
				}
			}

			self.snapshot.appendSections([.milestones(false)])
			self.snapshot.appendItems(milestoneItems, toSection: .milestones(false))

			// Add top percentile milestone
			if let recapItem = self.recapItems.filter({
				$0.attributes.topPercentile > 0.0
			})
			.sorted(by: { $0.attributes.topPercentile < $1.attributes.topPercentile })
			.first {
				let itemKind: ItemKind = .recapItem(recapItem, milestoneKind: .topPercentile)

				self.snapshot.appendSections([.milestones(true)])
				self.snapshot.appendItems([itemKind], toSection: .milestones(true))
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		return self.cache[indexPath] as? M
	}

	func setSectionNeedsUpdate(_ section: SectionLayoutKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfSection(section) != nil else { return }
		let itemsInSection = snapshot.itemIdentifiers(inSection: section)
		snapshot.reconfigureItems(itemsInSection)
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
