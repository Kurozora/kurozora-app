//
//  CastCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension CastCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [CastCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Cast>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Cast) -> UICollectionViewCell? in
			guard let castCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.castCollectionViewCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.castCollectionViewCell.identifier)")
			}
			castCollectionViewCell.delegate = self
			castCollectionViewCell.cast = item
			return castCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Cast>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.cast)
		dataSource.apply(snapshot)
	}
}
