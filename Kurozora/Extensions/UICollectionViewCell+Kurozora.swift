//
//  UICollectionViewCell+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
	/// Returns an instance of the tableView containing the cell.
	var parentCollectionView: UICollectionView? {
		return (next as? UICollectionView) ?? (parentViewController as? UICollectionViewController)?.collectionView
	}

	/// Returns the indexPath of the cell.
	var indexPath: IndexPath? {
		return parentCollectionView?.indexPathForItem(at: self.center)
	}
}
