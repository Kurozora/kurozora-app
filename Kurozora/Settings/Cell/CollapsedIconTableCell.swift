//
//  CollapsedIconTableCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class CollapsedIconTableCell: UITableViewCell {
	@IBOutlet weak var collectionView: UICollectionView!

	var numberOfCollapsedItems: Int!
	var icons = [UIImage]() {
		didSet {
			collectionView.reloadData()
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		collectionView.register(UINib(nibName: "CollapsedIconCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CollapsedIconCollectionCell")

		collectionView.dataSource = self
		collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource
extension CollapsedIconTableCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numberOfCollapsedItems
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collapsedIconCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollapsedIconCollectionCell", for: indexPath) as! CollapsedIconCollectionCell
		if icons.count != 0 {
			collapsedIconCollectionCell.iconImageView.image = icons[indexPath.row]
		}

		return collapsedIconCollectionCell
	}
}

// MARK: - UICollectionViewDelegate
extension CollapsedIconTableCell: UICollectionViewDelegate {
}
