//
//  FavoriteShowsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension FavoriteShowsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Show>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Show) -> UICollectionViewCell? in
			let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
			smallLockupCollectionViewCell.configureCell(with: item)
			return smallLockupCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Show>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.shows)
		self.snapshot = snapshot
		self.dataSource.apply(snapshot) { [weak self] in
			guard let self = self else { return }
			self.toggleEmptyDataView()
		}
	}
}
