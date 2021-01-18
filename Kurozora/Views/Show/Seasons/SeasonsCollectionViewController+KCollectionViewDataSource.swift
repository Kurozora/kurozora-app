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
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [LockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Season>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Season) -> UICollectionViewCell? in
			if let lockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.lockupCollectionViewCell, for: indexPath) {
				lockupCollectionViewCell.season = item
				return lockupCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.lockupCollectionViewCell.identifier)")
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Season>()
		snapshot.appendSections([.main])
		snapshot.appendItems(seasons)
		dataSource.apply(snapshot)
	}
}
