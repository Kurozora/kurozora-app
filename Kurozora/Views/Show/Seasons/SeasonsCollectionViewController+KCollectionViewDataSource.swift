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
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Season>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, season: Season) -> UICollectionViewCell? in
			guard let posterLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.posterLockupCollectionViewCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.posterLockupCollectionViewCell.identifier)")
			}
			posterLockupCollectionViewCell.configure(with: season)
			return posterLockupCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Season>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.seasons)
		self.dataSource.apply(snapshot)
	}
}
