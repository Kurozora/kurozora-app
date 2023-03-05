//
//  GamesListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

// MARK: - KCollectionViewDataSource
extension GamesListCollectionViewController {
	override func configureDataSource() {
		let gameLockupCellRegistration = UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity(let gameIdentity):
				let game = self.fetchGame(at: indexPath)
				var gameDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? gameLockupCollectionViewCell.dataRequest

				if gameDataRequest == nil && game == nil {
					gameDataRequest = KService.getDetails(forGame: gameIdentity) { result in
						switch result {
						case .success(let games):
							self.games[indexPath] = games.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				gameLockupCollectionViewCell.dataRequest = gameDataRequest
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			case .relatedGame(let relatedGame):
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: relatedGame)
			}
		}

		let upcomingLockupCellRegistration = UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.upcomingLockupCollectionViewCell)) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity(let gameIdentity):
				let game = self.fetchGame(at: indexPath)
				var gameDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? upcomingLockupCollectionViewCell.dataRequest

				if gameDataRequest == nil && game == nil {
					gameDataRequest = KService.getDetails(forGame: gameIdentity) { result in
						switch result {
						case .success(let games):
							self.games[indexPath] = games.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				upcomingLockupCollectionViewCell.dataRequest = gameDataRequest
				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}

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
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])

		// Append items
		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
				return .relatedGame(relatedGame)
			}
			snapshot.appendItems(relatedGameItems, toSection: .main)
		default:
			let gameItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
				return .gameIdentity(gameIdentity)
			}
			snapshot.appendItems(gameItems, toSection: .main)
		}

		self.dataSource.apply(snapshot)
	}

	func fetchGame(at indexPath: IndexPath) -> Game? {
		guard let game = self.games[indexPath] else { return nil }
		return game
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
