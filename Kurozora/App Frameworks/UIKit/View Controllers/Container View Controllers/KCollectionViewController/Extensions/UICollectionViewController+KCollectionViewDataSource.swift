//
//  UICollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension UICollectionViewController: KCollectionViewDataSource {
	/**
		Asks your data source object for the cells registered with the collection view.

		If you do not implement this method, the collection view uses a default value of an empty array.

		- Parameter collectionView: The collection view requesting this information.

		- Returns: The collection view cells registered with `collectionView`.

		- Tag: KCollectionViewDataSource-registerCellsForCollectionView
	*/
	func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return []
	}

	/**
		Asks your data source object to configure the data source of the collection view.
	*/
	func configureDataSource() {
	}
}
