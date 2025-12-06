//
//  UsersListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension UsersListCollectionViewController {
	override func configureDataSource() {
		let userLockupCellRegistration = self.getConfiguredUserCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch self.usersListFetchType {
			case .follow, .search:
				return collectionView.dequeueConfiguredReusableCell(using: userLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		switch self.usersListFetchType {
		case .follow, .search:
			let userItems: [ItemKind] = self.userIdentities.map { userIdentity in
				.userIdentity(userIdentity)
			}
			self.snapshot.appendItems(userItems, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}
}
