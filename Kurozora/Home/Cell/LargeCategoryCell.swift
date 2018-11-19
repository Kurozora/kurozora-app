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
    
    var homeViewController = HomeViewController()
    var shows: [JSON]? = nil {
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
        
        if let backgroundThumbnail = shows?[indexPath.row]["background_thumbnail"].stringValue, backgroundThumbnail != "" {
            let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
            let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
            largeCell.backgroundImageView.kf.indicatorType = .activity
            largeCell.backgroundImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_banner"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            largeCell.backgroundImageView.image = UIImage(named: "placeholder_banner")
        }
        
        if let title = shows?[indexPath.row]["title"].stringValue, title != "" {
            largeCell.titleLabel.text = title
        } else {
            largeCell.titleLabel.text = "Untitled"
        }
        
        return largeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let showId = shows?[indexPath.item]["id"].intValue {
            homeViewController.showDetailFor(showId)
        }
    }
}
