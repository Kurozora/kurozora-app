//
//  SeasonsListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension SeasonsListCollectionViewController {
	override func configureDataSource() {
		let posterCellRegistration = self.getConfiguredSeasonCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: posterCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		let seasonItems: [ItemKind] = self.seasonIdentities.map { seasonIdentity in
			.seasonIdentity(seasonIdentity)
		}
		self.snapshot.appendItems(seasonItems, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}
}
