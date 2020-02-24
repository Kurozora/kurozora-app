//
//  KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	The KCollectionViewDataSource protocol defines methods that guide you with managing the cells registered with the collection view. The methods of this protocol are all optional.
*/
@objc protocol KCollectionViewDataSource: class {
	@objc optional func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type]
	@objc optional func configureDataSource()
}

extension UICollectionViewController: KCollectionViewDataSource {
	/**
		Asks your data source object for the cells registered with the collection view.

		If you do not implement this method, the collection view uses a default value of an empty array.

		- Parameter collectionView: The collection view requesting this information.

		- Returns: The collection view cells registered with `collectionView`.

		- Tag: KCVC-registerCellsForCollectionView
	*/
	func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		numberOfSections(in: collectionView)
		return []
	}

	/**
		Asks your data source object to configure the data source of the collection view.
	*/
	func configureDataSource() {
	}
}
