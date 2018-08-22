//
//  LargeCellCategory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class LargeCategoryCell: CategoryCell {
    
    private let largeCellShowId = "largeShowCellId"
    
    override func setupViews() {
        super.setupViews()
        showsCollectionView.register(LargeShowCell.self, forCellWithReuseIdentifier: largeCellShowId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellShowId, for: indexPath) as! ShowCell
        cell.show = showCategory?.shows?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: frame.height - 32)
    }
    
    private class LargeShowCell: ShowCell {
        
        private let shadowView: UIImageView = {
            let iv = UIImageView()
            iv.image = UIImage(named: "shadow")
            iv.contentMode = .scaleToFill
            iv.layer.cornerRadius = 10
            iv.layer.masksToBounds = true
            return iv
        }()
        
        fileprivate override func setupViews() {
            titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
            
            shadowView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
            shadowView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
            
            // Prepare auto layout
            bannerThumbnail.translatesAutoresizingMaskIntoConstraints = false
            shadowView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add them to the view
            addSubview(bannerThumbnail)
            addSubview(shadowView)
            addSubview(titleLabel)
            
            // Banner view constraint
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bannerView": bannerThumbnail]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bannerView": bannerThumbnail]))
            
            // Shadow view constraint
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .leading, relatedBy: .equal, toItem: bannerThumbnail, attribute: .leading, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .trailing, relatedBy: .equal, toItem: bannerThumbnail, attribute: .trailing, multiplier: 1.0, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .bottom, relatedBy: .equal, toItem: bannerThumbnail, attribute: .bottom, multiplier: 1.0, constant: 0))
            
            // Title label constraint
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: bannerThumbnail, attribute: .leading, multiplier: 1.0, constant: 8))
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 8))
            
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: shadowView, attribute: .bottom, multiplier: 1.0, constant: 0))
        }
        
    }
}
