//
//  ReviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Cosmos

class ReviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var reviewerButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var reviewLabel: UILabel!
}
