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
	override func configureCell(with show: Show?, showDetailBadge: ShowDetail.Badge) {
		super.configureCell(with: show, showDetailBadge: showDetailBadge)
		guard let show = show else { return }

		// Configure rating view
		let ratingAverage = show.attributes.stats?.ratingAverage ?? 0.0
		self.cosmosView.rating = ratingAverage
		self.ratingScoreLabel.text = "\(ratingAverage)"
	}

	override func configureCell(with literature: Literature?, literatureDetailBadge: LiteratureDetail.Badge) {
		super.configureCell(with: literature, literatureDetailBadge: literatureDetailBadge)
		guard let literature = literature else { return }

		// Configure rating view
		let ratingAverage = literature.attributes.stats?.ratingAverage ?? 0.0
		self.cosmosView.rating = ratingAverage
		self.ratingScoreLabel.text = "\(ratingAverage)"
	}
}
