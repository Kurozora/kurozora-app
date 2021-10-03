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
		return [PosterLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Season>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Season) -> UICollectionViewCell? in
			if let posterLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.posterLockupCollectionViewCell, for: indexPath) {
				posterLockupCollectionViewCell.season = item
				return posterLockupCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.posterLockupCollectionViewCell.identifier)")
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
