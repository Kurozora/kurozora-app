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
	override func configureCell(with show: Show?) {
		super.configureCell(with: show)
		guard let show = show else { return }

		// Configure rating view
		let ratingAverage = show.attributes.stats?.ratingAverage ?? 0.0
		self.cosmosView.rating = ratingAverage
		self.ratingScoreLabel.text = "\(ratingAverage)"
	}
}
