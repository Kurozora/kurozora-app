//
//  LargeCategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LargeCategoryCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    var shows: [ExploreBanner]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension LargeCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let showsCount = shows?.count else { return 0 }
		return showsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let largeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeCell", for: indexPath) as! ExploreCell
        
        largeCell.showElement = shows?[indexPath.row]
        
        return largeCell
    }
}

// MARK: - UICollectionViewDelegate
extension LargeCategoryCell: UICollectionViewDelegate {
}
