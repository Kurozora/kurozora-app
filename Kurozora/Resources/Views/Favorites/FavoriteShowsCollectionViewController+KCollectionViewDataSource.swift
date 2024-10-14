//
//  FavoritesCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension FavoritesCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			GameLockupCollectionViewCell.self,
			SmallLockupCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			switch item {
			case .show(let show):
				let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
				smallLockupCollectionViewCell.configure(using: show)
				return smallLockupCollectionViewCell
			case .literature(let literature):
				let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
				smallLockupCollectionViewCell.configure(using: literature)
				return smallLockupCollectionViewCell
			case .game(let game):
				let gameLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: GameLockupCollectionViewCell.self, for: indexPath)
				gameLockupCollectionViewCell.configure(using: game)
				return gameLockupCollectionViewCell
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])

		switch self.libraryKind {
		case .shows:
			let shows: [ItemKind] = self.shows.map { show in
				return .show(show)
			}
			snapshot.appendItems(shows, toSection: .main)
		case .literatures:
			let literatures: [ItemKind] = self.literatures.map { literature in
				return .literature(literature)
			}
			snapshot.appendItems(literatures, toSection: .main)
		case .games:
			let games: [ItemKind] = self.games.map { game in
				return .game(game)
			}
			snapshot.appendItems(games, toSection: .main)
		}

		self.snapshot = snapshot
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
