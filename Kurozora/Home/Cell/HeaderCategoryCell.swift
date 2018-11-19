//
//  HeaderCategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let bannersCount = banners?.count, bannersCount != 0 {
            return bannersCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
        
        if let backgroundThumbnail = banners?[indexPath.row]["background_thumbnail"].stringValue, backgroundThumbnail != "" {
            let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
            let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
            headerCell.backgroundImageView.kf.indicatorType = .activity
            headerCell.backgroundImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_banner"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            headerCell.backgroundImageView.image = UIImage(named: "placeholder_banner")
        }
        
        if let title = banners?[indexPath.row]["title"].stringValue, title != "" {
            headerCell.titleLabel.text = title
        } else {
            headerCell.titleLabel.text = "Untitiled"
        }
        
        if let genre = banners?[indexPath.row]["genre"].stringValue, genre != "" {
            headerCell.genreLabel.text = genre
        } else {
            headerCell.genreLabel.text = ""
        }
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerId = banners?[indexPath.item]["id"].intValue {
            self.performSegue(withIdentifier: "ShowDetailsSegue", sender: bannerId)
        }
    }
}
