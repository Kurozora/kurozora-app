//
//  CategoryRowViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ShowCategoryCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let homeViewController = HomeViewController()
    var shows: [ExploreBanner]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
}

extension ShowCategoryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let showsCount = shows?.count, showsCount != 0 {
            return showsCount
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let showCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! ShowCell
        
        // Show poster
        if let posterThumbnail = shows?[indexPath.row].posterThumbnail, posterThumbnail != "" {
            let posterThumbnailUrl = URL(string: posterThumbnail)
            let resource = ImageResource(downloadURL: posterThumbnailUrl!)
            showCell.posterImageView.kf.indicatorType = .activity
            showCell.posterImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            showCell.posterImageView.image = UIImage(named: "placeholder_poster")
        }
        
        // Show title
        if let title = shows?[indexPath.row].title {
            showCell.titleLabel.text = title
        }
        
        // Show genre
        if let genre = shows?[indexPath.row].genre {
            showCell.genreLabel.text = genre
        }
        
        // Show score
        if let score = shows?[indexPath.row].averageRating, score != 0 {
            showCell.scoreLabel.text = " \(score)"
            // Change color based on score
            if score >= 2.5 {
                showCell.scoreLabel.backgroundColor = UIColor.init(red: 255/255.0, green: 177/255.0, blue: 10/255.0, alpha: 1.0)
            } else {
                showCell.scoreLabel.backgroundColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 67/255.0, alpha: 1.0)
            }
        } else {
            showCell.scoreLabel.text = "New"
            showCell.scoreLabel.backgroundColor = UIColor.init(red: 51/255.0, green: 204/255.0, blue: 0/255.0, alpha: 1.0)
        }
        
        return showCell
    }
}
