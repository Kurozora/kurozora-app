//
//  CastListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension CastListCollectionViewController {
	override func configureDataSource() {
		let castCellRegistration = self.getCastCellRegistration()
		let characterCellRegistration = self.getCharacterCellRegistration()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch self.castKind {
			case .show, .game:
				return collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: itemKind)
			case .literature:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		let castItems: [ItemKind] = self.castIdentities.map { castIdentity in
			.castIdentity(castIdentity)
		}
		self.snapshot.appendItems(castItems, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}
}
