//
//  KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// The KCollectionViewDataSource protocol defines methods that guide you with managing the cells registered with the collection view. The methods of this protocol are all optional.
///
/// - Tag: KCollectionViewDataSource
@objc protocol KCollectionViewDataSource: AnyObject {
	@objc optional func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type]
	@objc optional func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type]
	@objc optional func updateDataSource()
	@MainActor @objc optional func configureDataSource()
}

// MARK: - KCollectionViewController
extension KCollectionViewController: KCollectionViewDataSource {
	/// Asks your data source object for the cells registered with the `collectionView`.
	///
	/// If you do not implement this method, the collection view uses a default value of an empty array.
	///
	/// - Parameter collectionView: The collection view requesting this information.
	///
	/// - Returns: The collection view cells registered with `collectionView`.
	///
	/// - Tag: KCollectionViewDataSource-registerCellsForCollectionView
	func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return []
	}

	/// Asks your data source object for the reusable views registered with the `collectionView`.
	///
	/// If you do not implement this method, the collection view uses a default value of an empty array.
	///
	/// - Parameter collectionView: The collection view requesting this information.
	///
	/// - Returns: The collection view reusable views registered with `collectionView`.
	///
	/// - Tag: KCollectionViewDataSource-registerNibsForCollectionView
	func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return []
	}

	/// Asks your data source object to configure the data source of the collection view.
	func configureDataSource() {}

	/// Asks your data source object to update the data source of the collection view.
	func updateDataSource() {}
}
