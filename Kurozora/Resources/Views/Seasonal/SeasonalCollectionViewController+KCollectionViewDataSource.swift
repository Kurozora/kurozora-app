//
//  SeasonalCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SeasonalCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellConfiguration = self.getConfiguredSmallCell()
		let gameCellConfiguration = self.getConfiguredGameCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let section = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch section {
			case .browseSeason(let browseSeason):
				if browseSeason.relationships.games != nil {
					return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
				}

				return collectionView.dequeueConfiguredReusableCell(using: smallCellConfiguration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)

			switch sectionLayoutKind {
			case .browseSeason(let browseSeason):
				let count = self.itemCount(in: browseSeason)
				exploreSectionTitleCell.configure(withTitle: "\(browseSeason.attributes.type.name) (\(count))", segueID: nil, separatorIsHidden: true)
			}

			return exploreSectionTitleCell
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		for browseSeason in self.filteredBrowseSeasons {
			let sectionHeader: SectionLayoutKind = .browseSeason(browseSeason)
			var itemKinds: [ItemKind] = []

			if let shows = browseSeason.relationships.shows?.data {
				itemKinds = shows.map { show in
					.show(show, section: sectionHeader)
				}
			} else if let literatures = browseSeason.relationships.literatures?.data {
				itemKinds = literatures.map { literature in
					.literature(literature, section: sectionHeader)
				}
			} else if let games = browseSeason.relationships.games?.data {
				itemKinds = games.map { game in
					.game(game, section: sectionHeader)
				}
			}

			self.snapshot.appendSections([sectionHeader])
			self.snapshot.appendItems(itemKinds, toSection: sectionHeader)
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
