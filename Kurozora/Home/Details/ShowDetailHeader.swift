//
//  ShowDetailHeader.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class ShowDetailHeader: BaseCell {
    
    var showDetails: Show? {
        didSet {
            guard let showDetails = showDetails else { return }
            configure(showDetails)
        }
    }
    
    private let posterThumbnailView: CachedImageView = {
        let pt = CachedImageView()
        pt.contentMode = .scaleAspectFill
        pt.layer.masksToBounds = true
        return pt
    }()
    
    private let bannerView: CachedImageView = {
        let bt = CachedImageView()
        bt.contentMode = .scaleAspectFill
        bt.layer.masksToBounds = true
        return bt
    }()
    
//    private let segmentedControl: UISegmentedControl = {
//        let sc = UISegmentedControl(items: ["Details", "Episode", "Related"])
//        sc.tintColor = .lightGray
//        sc.selectedSegmentIndex = 0
//        return sc
//    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    let runtimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
        return view
    }()
    
    override func setupViews() {
        
        // Prepare auto layout
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        //        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        posterThumbnailView.translatesAutoresizingMaskIntoConstraints = false
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add them to the view
        addSubview(bannerView)
        addSubview(titleLabel)
        addSubview(infoLabel)
        //        addSubview(segmentedControl)
        addSubview(posterThumbnailView)
        addSubview(dividerLineView)
        
        // Banner view constraint
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bannerView": bannerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["bannerView": bannerView]))
        
        addConstraint(NSLayoutConstraint(item: bannerView, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 15))
        
        // Title view constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: bannerView, attribute: .bottom, multiplier: 1.0, constant: 2))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: bannerView, attribute: .leading, multiplier: 1.0, constant: 15))
        
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: infoLabel, attribute: .trailing, multiplier: 1.0, constant: 0))
        
        // Info view constraint
        addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: 0))
        
        // Poster view constraint
        addConstraint(NSLayoutConstraint(item: posterThumbnailView, attribute: .leading, relatedBy: .equal, toItem: infoLabel, attribute: .leading, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: posterThumbnailView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85))
        addConstraint(NSLayoutConstraint(item: posterThumbnailView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 124))
        
        addConstraint(NSLayoutConstraint(item: posterThumbnailView, attribute: .top, relatedBy: .equal, toItem: infoLabel, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        // Divider line view constraint
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(0.5)]|", views: dividerLineView)
    }
    
    private func configure(_ show: Show?) {
        
        // Configure banner view
        if let bannerUrl = show?.banner {
            bannerView.loadImage(urlString: bannerUrl)
        } else {
            bannerView.image = UIImage(named: "colorful")
        }
        
        // Configure title label
        if let title = show?.title {
            titleLabel.text = title
        } else {
            titleLabel.text = "Undefined"
        }
        
        // Configure runtime label
        if let runtime = show?.runtime {
            runtimeLabel.text = String(runtime)
        } else {
            runtimeLabel.text = "0"
        }
        
        // Configure rating label
        if let rating = show?.watchRating {
            ratingLabel.text = rating
        } else {
            ratingLabel.text = "N/A"
        }
        
        // Configure info label
        if let info = show?.watchRating {
            infoLabel.text =  info
        } else {
            infoLabel.text = "Unknown · N/A · 0 eps · 0 min · 0000"
        }
        
        // Configure poster view
        if let posterThumbnailUrl = show?.posterThumbnail {
            posterThumbnailView.loadImage(urlString: posterThumbnailUrl)
        } else {
            posterThumbnailView.image = UIImage(named: "aozora")
        }
    }
}
