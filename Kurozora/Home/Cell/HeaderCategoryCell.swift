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
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		stopHeaderColelctionTimer()
	}

	@objc func scrollToNextCell() {
		let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)

		guard let indexPathItem = visibleIndexPath?.item, let indexPathSection = visibleIndexPath?.section else { return }
		let indexPath = IndexPath(item: indexPathItem + 1, section: indexPathSection)
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
	}

	func startHeaderCollectionTimer() {
//		headerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
	}

	func stopHeaderColelctionTimer() {
		if headerTimer != nil {
			headerTimer?.invalidate()
			headerTimer = nil
		}
	}

// Collection view
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
        
        if let background = banners?[indexPathRow].background, background != "" {
            let backgroundUrl = URL(string: background)
            let resource = ImageResource(downloadURL: backgroundUrl!)
            headerCell.backgroundImageView.kf.indicatorType = .activity
            headerCell.backgroundImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
        } else {
            headerCell.backgroundImageView.image = #imageLiteral(resourceName: "placeholder_banner")
        }
        
        if let title = banners?[indexPathRow].title, let id = banners?[indexPathRow].id {
			headerCell.titleLabel.text = "\(id): " + title
        }
        
        if let genre = banners?[indexPathRow].genre {
            headerCell.genreLabel.text = genre
        }
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerID = banners?[indexPath.item].id {
            self.performSegue(withIdentifier: "ShowDetailsSegue", sender: bannerID)
        }
    }

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if !onceOnly {
			let size = collectionView.contentSize
			let topLeftCoordinatesWhenCentered = CGPoint(x: (size.width - collectionView.frame.width) * 0.5, y: (size.height - collectionView.frame.height) * 0.5)
			collectionView.setContentOffset(topLeftCoordinatesWhenCentered, animated: false)

			onceOnly = true
		}
	}

	// MARK: - Flowlayout
	func collectionView(_ collectionView: UICollectionView,	layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return itemSize
	}
}
