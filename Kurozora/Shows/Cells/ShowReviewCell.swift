//
//  ShowReviewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class ShowReviewCell: UITableViewCell {
    @IBOutlet weak var reviewerLabel: UILabel!
    @IBOutlet weak var reviewerAvatar: UIImageView!
    @IBOutlet weak var reviewerOverallScoreLabel: UILabel!
    @IBOutlet weak var reviewerReviewLabel: UILabel!
    @IBOutlet weak var reviewStatisticsLabel: UILabel!
    @IBOutlet weak var reviewHeightConstraint: NSLayoutConstraint!
}
