//
//  HeaderCategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
		guard let bannersCount = banners?.count else { return headerCell }
		let indexPathRow = indexPath.row % bannersCount
        
        if let backgroundThumbnail = banners?[indexPathRow]["background_thumbnail"].stringValue, backgroundThumbnail != "" {
            let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
            let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
            headerCell.backgroundImageView.kf.indicatorType = .activity
            headerCell.backgroundImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            headerCell.backgroundImageView.image = #imageLiteral(resourceName: "placeholder_banner")
        }
        
        if let title = banners?[indexPathRow]["title"].stringValue {
            headerCell.titleLabel.text = title
        }
        
        if let genre = banners?[indexPathRow]["genre"].stringValue {
            headerCell.genreLabel.text = genre
        }
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerID = banners?[indexPath.item]["id"].intValue {
            self.performSegue(withIdentifier: "ShowDetailsSegue", sender: bannerID)
        }
    }

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if !onceOnly {
			if let bannersCount = banners?.count, bannersCount != 0 {
				self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
				onceOnly = true
			}
		}
	}

	// MARK: - Flowlayout
	func collectionView(_ collectionView: UICollectionView,	layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return itemSize
	}
}
