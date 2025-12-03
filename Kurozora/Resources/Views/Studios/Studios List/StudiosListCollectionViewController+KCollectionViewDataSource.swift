//
//  StudiosListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension StudiosListCollectionViewController {
	override func configureDataSource() {
		let studioCellRegistration = self.getConfiguredStudioCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: studioCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		switch self.studiosListFetchType {
		case .game, .literature, .search, .show:
			let studioItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
				.studioIdentity(studioIdentity)
			}
			self.snapshot.appendItems(studioItems, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}
}
