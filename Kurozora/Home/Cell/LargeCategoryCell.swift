//
//  LargeCategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class LargeCategoryCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var separatorView: UIView!

    var homeViewController = HomeViewController()
    var shows: [ExploreBanner]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
}

extension LargeCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let showsCount = shows?.count, showsCount != 0 {
            return showsCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let largeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeCell", for: indexPath) as! LargeCell
        
        if let backgroundThumbnail = shows?[indexPath.row].backgroundThumbnail, backgroundThumbnail != "" {
            let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
            let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
            largeCell.backgroundImageView.kf.indicatorType = .activity
			largeCell.backgroundImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
        } else {
            largeCell.backgroundImageView.image = #imageLiteral(resourceName: "placeholder_banner")
        }
        
        if let title = shows?[indexPath.row].title {
            largeCell.titleLabel.text = title
        }
        
        return largeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let showId = shows?[indexPath.item].id {
            homeViewController.showDetailFor(showId)
        }
    }
}
