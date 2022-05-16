//
//  SeasonsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension SeasonsCollectionViewController {
	override func configureDataSource() {
		let posterCellRegistration = UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, SeasonIdentity>(cellNib: UINib(resource: R.nib.seasonLockupCollectionViewCell)) { [weak self] seasonLockupCollectionViewCell, indexPath, seasonIdentity in
			guard let self = self else { return }
			let season = self.fetchSeason(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? seasonLockupCollectionViewCell.dataRequest

			if dataRequest == nil && season == nil {
				dataRequest = KService.getDetails(forSeason: seasonIdentity) { [weak self] result in
					switch result {
					case .success(let seasons):
						self?.seasons[indexPath] = seasons.first
						self?.setSeasonNeedsUpdate(seasonIdentity)
					case .failure: break
					}
				}
			}

			seasonLockupCollectionViewCell.dataRequest = dataRequest
			seasonLockupCollectionViewCell.configure(using: season)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, SeasonIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, seasonIdentity: SeasonIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: posterCellRegistration, for: indexPath, item: seasonIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, SeasonIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.seasonIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchSeason(at indexPath: IndexPath) -> Season? {
		guard let season = self.seasons[indexPath] else { return nil }
		return season
	}

	func setSeasonNeedsUpdate(_ seasonIdentity: SeasonIdentity) {
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([seasonIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
