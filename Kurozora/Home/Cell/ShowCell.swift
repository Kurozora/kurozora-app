//
//  ShowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class ShowCell: UICollectionViewCell {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
}

class LargeCell: UICollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var shadowImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

class HeaderCell: UICollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var shadowImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
}
