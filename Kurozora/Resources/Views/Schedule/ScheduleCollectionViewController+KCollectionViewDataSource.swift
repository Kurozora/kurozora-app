//
//  ScheduleCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ScheduleCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let gameCellConfiguration = self.getConfiguredGameCell()
		let smallCellConfiguration = self.getConfiguredSmallCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let recapSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch recapSection {
			case .schedule(let schedule):
				if schedule.relationships.shows != nil {
					return collectionView.dequeueConfiguredReusableCell(using: smallCellConfiguration, for: indexPath, item: itemKind)
				} else if schedule.relationships.literatures != nil {
					return collectionView.dequeueConfiguredReusableCell(using: smallCellConfiguration, for: indexPath, item: itemKind)
				} else if schedule.relationships.games != nil {
					return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
				}
			}

			return nil
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			var title: String = ""

			switch sectionLayoutKind {
			case .schedule(let schedule):
				let dateFormatter = DateFormatter.app
				dateFormatter.dateFormat = "EEEE MMM d"
				title = dateFormatter.string(from: schedule.attributes.date)

				if let showsCount = schedule.relationships.shows?.data.count {
					title += " (\(showsCount))"
				} else if let literaturesCount = schedule.relationships.literatures?.data.count {
					title += " (\(literaturesCount))"
				} else if let gamesCount = schedule.relationships.games?.data.count {
					title += " (\(gamesCount))"
				}
			}

			exploreSectionTitleCell.configure(withTitle: title, segueID: nil, separatorIsHidden: true)

			// Return the view.
			return exploreSectionTitleCell
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		// Add schedules
		for schedule in self.schedules {
			let sectionHeader: SectionLayoutKind = .schedule(schedule)
			var itemKinds: [ItemKind] = []

			if let shows = schedule.relationships.shows?.data {
				itemKinds = shows.map { show in
					.show(show, section: sectionHeader)
				}
			} else if let literatures = schedule.relationships.literatures?.data {
				itemKinds = literatures.map { literature in
					.literature(literature, section: sectionHeader)
				}
			} else if let games = schedule.relationships.games?.data {
				itemKinds = games.map { game in
					.game(game, section: sectionHeader)
				}
			}

			self.snapshot.appendSections([sectionHeader])
			self.snapshot.appendItems(itemKinds, toSection: sectionHeader)
		}

		self.dataSource.apply(self.snapshot)
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension ScheduleCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .show(let show, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show, scheduleIsShown: true)
			case .literature(let literature, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature, scheduleIsShown: true)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .game(let game, _):
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game, scheduleIsShown: true)
			default: break
			}
		}
	}
}
