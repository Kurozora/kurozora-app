//
//  CategoryRowViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class ShowCategoryCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    var shows: [ExploreBanner]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ShowCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let showsCount = shows?.count else { return 0 }
		return showsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let showCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! ExploreCell
        
        showCell.showElement = shows?[indexPath.row]
        
        return showCell
    }
}

// MARK: - UICollectionViewDelegate
extension ShowCategoryCell: UICollectionViewDelegate {
}
