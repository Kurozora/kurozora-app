//
//  PeopleListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension PeopleListCollectionViewController {
	override func configureDataSource() {
		let personCellRegistration = self.getConfiguredPersonCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		switch self.peopleListFetchType {
		case .character, .explore, .search:
			let personItems: [ItemKind] = self.personIdentities.map { personIdentity in
				.personIdentity(personIdentity)
			}
			self.snapshot.appendItems(personItems, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}
}
