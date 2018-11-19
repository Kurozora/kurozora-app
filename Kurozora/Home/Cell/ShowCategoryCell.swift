//
//  CategoryRowViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class ShowCategoryCell: UITableViewCell {}
class LargeCategoryCell: UITableViewCell {}

extension ShowCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let showCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! PosterCell
        return showCell
    }
}

extension LargeCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let showCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeCell", for: indexPath) as! LargeCell
        return showCell
    }
}
