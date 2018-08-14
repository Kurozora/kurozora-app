//
//  PosterCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class PosterCell: UICollectionViewCell {

    static let id = "PosterCell"
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    class func registerNibFor(collectionView: UICollectionView) {
        let posterNib = UINib(nibName: PosterCell.id, bundle: nil)
        collectionView.register(posterNib, forCellWithReuseIdentifier: PosterCell.id)
    }

}
