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
	@objc optional func configureDataSource()
}
