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
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        return label
    }()
    
    override func setupViews() {
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(priceLabel)
        
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        nameLabel.frame = CGRect(x: 0, y: frame.width + 2, width: frame.width, height: 40)
        categoryLabel.frame = CGRect(x: 0, y: frame.width + 38, width: frame.width, height: 20)
        priceLabel.frame = CGRect(x: 0, y: frame.width + 56, width: frame.width, height: 20)
    }
    
    private func configure(_ show: Show) {
        if let name = show.title {
            nameLabel.text = name
            let rect = String(name).boundingRect(with: CGSize(width: frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
            if rect.height > 20 {
                categoryLabel.frame = CGRect(x: 0, y: frame.width + 38, width: frame.width, height: 20)
                priceLabel.frame = CGRect(x: 0, y: frame.width + 56, width: frame.width, height: 20)
            } else {
                categoryLabel.frame = CGRect(x: 0, y: frame.width + 22, width: frame.width, height: 20)
                priceLabel.frame = CGRect(x: 0, y: frame.width + 40, width: frame.width, height: 20)
            }
            nameLabel.frame = CGRect(x: 0, y: frame.width + 5, width: frame.width, height: 40)
            nameLabel.sizeToFit()
        }
        
        if let category = show.genre {
            categoryLabel.text = category
        }
        
        if let price = show.score {
            priceLabel.text = "Rank: \(price)"
        } else {
            priceLabel.text = "Rank: 9999"
        }
        
        if let imageName = show.imageName {
            do {
                let url = URL(string: imageName)
                let data = try Data(contentsOf: url!)
                imageView.image = UIImage(data: data)
            }
            catch{
                print(error)
            }
        }
    }
    
}
