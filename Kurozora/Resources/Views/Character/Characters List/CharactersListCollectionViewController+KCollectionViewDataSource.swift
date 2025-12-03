//
//  CharactersListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension CharactersListCollectionViewController {
	override func configureDataSource() {
		let characterCellRegistration = self.getConfiguredCharacterCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		switch self.charactersListFetchType {
		case .explore, .person, .search:
			let characterItems: [ItemKind] = self.characterIdentities.map { characterIdentity in
				.characterIdentity(characterIdentity)
			}
			self.snapshot.appendItems(characterItems, toSection: .main)
		}

		self.dataSource.apply(snapshot)
	}
}
