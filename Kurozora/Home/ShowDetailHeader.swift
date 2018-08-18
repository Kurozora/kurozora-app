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
    
    private let posterView: UIImageView = {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TEXT"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(posterView)
        addSubview(segmentedControl)
        addSubview(titleLabel)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat(format: "H:|-14-[v0(100)]-8-[v1]|", views: posterView, titleLabel)
        addConstraintsWithFormat(format: "V:|-14-[v0(100)]|", views: posterView)
        
        addConstraintsWithFormat(format: "V:|-14-[v0(20)]", views: titleLabel)
        
        addConstraintsWithFormat(format: "H:|-40-[v0]-40-|", views: segmentedControl)
        addConstraintsWithFormat(format: "V:[v0(34)]-8-|", views: segmentedControl)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(0.5)]|", views: dividerLineView)
    }
    
    private func configure(_ show: Show) {
        if let posterUrl = show.posterUrl {
            do {
                let url = URL(string: posterUrl)
                let data = try Data(contentsOf: url!)
                posterView.image = UIImage(data: data)
            }
            catch{
                print(error)
            }
        }
        titleLabel.text = show.title
    }
}
