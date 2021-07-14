//
//  RatingBadgeCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/07/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RatingBadgeCollectionViewCell: BadgeCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var ratingScoreLabel: KTintedLabel!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		// Configure rating view
		let averageRating = show.attributes.userRating.averageRating
		cosmosView.rating = averageRating
		ratingScoreLabel.text = "\(averageRating)"
	}
}
