//
//  GamesListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

extension GamesListCollectionViewController {
	override func configureDataSource() {
		let gameLockupCellRegistration = self.getConfiguredGameCell()
		let upcomingLockupCellRegistration = self.getConfiguredUpcomingCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch self.gamesListFetchType {
			case .upcoming:
				return collectionView.dequeueConfiguredReusableCell(using: upcomingLockupCellRegistration, for: indexPath, item: itemKind)
			default:
				return collectionView.dequeueConfiguredReusableCell(using: gameLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
				.relatedGame(relatedGame)
			}
			self.snapshot.appendItems(relatedGameItems, toSection: .main)
		default:
			let gameItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
				.gameIdentity(gameIdentity)
			}
			self.snapshot.appendItems(gameItems, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}
}
