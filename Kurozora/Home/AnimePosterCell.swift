//
//  AnimePosterCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class AnimePosterCell: UICollectionViewCell {

    static let id = "AnimePosterCell"
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func registerNibFor(collectionView: UICollectionView) {
        let chartNib = UINib(nibName: AnimePosterCell.id, bundle: nil)
        collectionView.register(chartNib, forCellWithReuseIdentifier: AnimePosterCell.id)
    }

}
