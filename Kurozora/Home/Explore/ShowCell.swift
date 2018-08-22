//
//  ShowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class ShowCell: BaseCell {
    
    var show: Show? {
        didSet {
            guard let show = show else { return }
            configure(show)
        }
    }
    
    private let posterThumbnail: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let bannerThumbnail: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.init(red: 149/255.0, green: 157/255.0, blue: 173/255.0, alpha: 1.0)
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "FontAwesome", size: 13)
        label.textColor = .white
        label.backgroundColor = UIColor.init(red: 255/255.0, green: 177/255.0, blue: 10/255.0, alpha: 1.0)
        label.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override func setupViews() {
        // Prepare auto layout
        posterThumbnail.translatesAutoresizingMaskIntoConstraints = false
        bannerThumbnail.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add them to the view
        addSubview(posterThumbnail)
        addSubview(titleLabel)
        addSubview(genreLabel)
        addSubview(scoreLabel)
        
        // Place them nicely
        posterThumbnail.frame = CGRect(x: 0, y: 10, width: 85, height: 124)
        titleLabel.frame = CGRect(x: 0, y: posterThumbnail.frame.maxY + 2, width: 85, height: titleLabel.frame.height)
        genreLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY, width: 85, height: 16)
        scoreLabel.frame = CGRect(x: 18, y: 0, width: 48, height: 20)
    }
    
    func configure(_ show: Show?) {
        
        // Configure title label
        if let title = show?.title {
            titleLabel.text = title
            
            // Emulate a label with title inside - NEEDS TO BE REWRITTEN MORE EFFICIENTLY
            let rect = String(title).boundingRect(with: CGSize(width: 85, height: 168), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13)], context: nil)
            
            // Change label height programmatically
            if rect.height > 20 {
                genreLabel.frame = CGRect(x: 0, y: 168, width: 85, height: 16)
            } else {
                genreLabel.frame = CGRect(x: 0, y: 152.5, width: 85, height: 16)
            }
            
            titleLabel.sizeToFit()
        } else {
            titleLabel.text = "Undefined"
            titleLabel.sizeToFit()
        }
        
        // Configure genre label
        if let genre = show?.genre {
            genreLabel.text = genre
        } else {
            genreLabel.text = "N/A"
        }
        
        // Configure score label
        if let score = show?.score {
            scoreLabel.text = " \(score)"
            
            // Change color based on score
            if score > 5.0 {
                scoreLabel.backgroundColor = UIColor.init(red: 255/255.0, green: 177/255.0, blue: 10/255.0, alpha: 1.0)
            } else {
                scoreLabel.backgroundColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 67/255.0, alpha: 1.0)
            }
        } else {
            scoreLabel.text = " 0.00"
            scoreLabel.backgroundColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 67/255.0, alpha: 1.0)
        }
        
        // Configure poster url
        if let posterThumbnailUrl = show?.posterThumbnail {
            posterThumbnail.loadImage(urlString: posterThumbnailUrl)
        } else {
            posterThumbnail.image = UIImage(named: "colorful")
        }
        
        // Configure banner url
        if let bannerThumbnailUrl = show?.bannerThumbnail {
            bannerThumbnail.loadImage(urlString: bannerThumbnailUrl)
        } else {
            bannerThumbnail.image = UIImage(named: "aozora")
        }
    }
    
}
