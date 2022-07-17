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

			if season == nil {
				Task {
					do {
						let seasonResponse = try await KService.getDetails(forSeason: seasonIdentity).value
						self.seasons[indexPath] = seasonResponse.data.first
						self.setSeasonNeedsUpdate(seasonIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

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
