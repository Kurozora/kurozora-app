//
//  ShowDetailHeader.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class ShowDetailHeader: BaseCell {
    
    var show: Show? {
        didSet {
            guard let show = show else { return }
            configure(show)
        }
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Details", "Episode", "Related"])
        sc.tintColor = .darkGray
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "TEXT"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Watch", for: .normal)
        button.layer.borderColor = UIColor(red: 0, green: 129/255, blue: 250/255, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    private let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(imageView)
        addSubview(segmentedControl)
        addSubview(nameLabel)
        addSubview(buyButton)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat(format: "H:|-14-[v0(100)]-8-[v1]|", views: imageView, nameLabel)
        addConstraintsWithFormat(format: "V:|-14-[v0(100)]|", views: imageView)
        
        addConstraintsWithFormat(format: "V:|-14-[v0(20)]", views: nameLabel)
        
        addConstraintsWithFormat(format: "H:|-40-[v0]-40-|", views: segmentedControl)
        addConstraintsWithFormat(format: "V:[v0(34)]-8-|", views: segmentedControl)
        
        addConstraintsWithFormat(format: "H:[v0(60)]-14-|", views: buyButton)
        addConstraintsWithFormat(format: "V:[v0(32)]-56-|", views: buyButton)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(0.5)]|", views: dividerLineView)
    }
    
    private func configure(_ show: Show) {
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
        nameLabel.text = show.title
        
        if let price = show.score {
            buyButton.setTitle("Rank: \(price)", for: .normal)
        }
    }
}
