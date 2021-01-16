//
//  LibraryListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension LibraryListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return []
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Show>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Show) -> UICollectionViewCell? in
			if let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.libraryCellStyle.identifierString, for: indexPath) as? LibraryBaseCollectionViewCell {
				libraryBaseCollectionViewCell.show = item
				return libraryBaseCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.castCollectionViewCell.identifier)")
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Show>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.shows)
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}
