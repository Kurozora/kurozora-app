//
//  HeaderCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import Kingfisher

class Header: CategoryCell {
    
    let bannerCellId = "bannerCellId"
    
    override func setupViews() {
        super.setupViews()
        titleLabel.removeFromSuperview()
        
        showsCollectionView.register(BannerCell.self, forCellWithReuseIdentifier: bannerCellId)
        
        showsCollectionView.dataSource = self
        showsCollectionView.delegate = self
        showsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Shows collection view constraint
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": showsCollectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": showsCollectionView]))
    }
    
    // Collection view items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = featuredShows?.count { return count }
        return 0
    }
    
    // Collection header item cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellId, for: indexPath) as! BannerCell
        cell.banner = featuredShows?[indexPath.item]
        return cell
    }
    
    // Collection header item size
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.isLandscape() {
            if UIDevice.isPad() {
                return CGSize(width: frame.width / 2 + 15, height: frame.height)
            }
        }
        return CGSize(width: frame.width / 2 + 50, height: frame.height)
    }
    
    // Collection header insets
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // Collection view item selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let banner = featuredShows?[indexPath.item] {
            featuredShowsViewController?.showDetailFor(banner)
        }
    }
    
    // Top banner
    fileprivate class BannerCell: ShowCell {
        
        var banner: Show? {
            didSet {
                guard let banner = banner else { return }
                configure(banner)
            }
        }
        
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
            
            // Prepare auto layout
            bannerThumbnail.translatesAutoresizingMaskIntoConstraints = false
            shadowView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            genreLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add them to the view
            addSubview(bannerThumbnail)
            addSubview(shadowView)
            addSubview(titleLabel)
            addSubview(genreLabel)
            
            // Banner view constraint
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bannerView": bannerThumbnail]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bannerView": bannerThumbnail]))
            
            // Shaodw view constraint
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .leading, relatedBy: .equal, toItem: bannerThumbnail, attribute: .leading, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .trailing, relatedBy: .equal, toItem: bannerThumbnail, attribute: .trailing, multiplier: 1.0, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .bottom, relatedBy: .equal, toItem: bannerThumbnail, attribute: .bottom, multiplier: 1.0, constant: 0))
            
            // Title label constraint
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: shadowView, attribute: .leading, multiplier: 1.0, constant: 8))
            addConstraint(NSLayoutConstraint(item: shadowView, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 8))
            
            // Genre label constraint
            addConstraint(NSLayoutConstraint(item: genreLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: genreLabel, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: genreLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: genreLabel, attribute: .bottom, relatedBy: .equal, toItem: shadowView, attribute: .bottom, multiplier: 1.0, constant: 0))
        }
        
        fileprivate override func configure(_ show: Show?) {
            // Configure title label
            if let title = show?.title, title != "" {
                titleLabel.text = title
            } else {
                titleLabel.text = "Undefined"
            }
            
            // Configure genre label
            if let genre = show?.genre, genre != "" {
                genreLabel.text = genre
            } else {
                genreLabel.text = "N/A"
            }
            
            // Configure banner url
            if let bannerThumbnailUrl = show?.bannerThumbnail, bannerThumbnailUrl != "" {
                let bannerThumbnailUrl = URL(string: bannerThumbnailUrl)
                let resource = ImageResource(downloadURL: bannerThumbnailUrl!)
                bannerThumbnail.kf.indicatorType = .activity
                bannerThumbnail.kf.setImage(with: resource, placeholder: UIImage(named: "colorful"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            } else {
                bannerThumbnail.image = UIImage(named: "colorful")
            }
        }
    }
}
