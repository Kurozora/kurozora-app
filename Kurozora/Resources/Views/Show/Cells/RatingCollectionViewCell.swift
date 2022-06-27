//
//  RatingCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol RatingCollectionViewCellDelegate: AnyObject {
	func rateShow(with rating: Double)
	func rateEpisode(with rating: Double)
}

class RatingCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var cosmosDetailLabel: KSecondaryLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet weak var ratingDetailLabel: KSecondaryLabel!

	// MARK: - Properties
	weak var delegate: RatingCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using show: Show) {
		// Configure cosmos view
		let userRating = show.attributes.givenRating
		self.cosmosView.rating = userRating ?? 0.0

		self.cosmosView.didFinishTouchingCosmos = { rating in
			WorkflowController.shared.isSignedIn {
				self.delegate?.rateShow(with: rating)
			}

			if !User.isSignedIn {
				self.cosmosView.rating = 0.0
			}
		}

		// Configure average rating
		self.ratingLabel.text = "\(show.attributes.stats?.ratingAverage ?? 0.0)"

		// Configure rating count
		let ratingCount = show.attributes.stats?.ratingCount ?? 0
		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}

	/// Configure the cell with the episode details.
	func configure(using episode: Episode) {
		// Configure cosmos view
		let userRating = episode.attributes.givenRating
		self.cosmosView.rating = userRating ?? 0.0

		self.cosmosView.didFinishTouchingCosmos = { rating in
			WorkflowController.shared.isSignedIn {
				self.delegate?.rateEpisode(with: rating)
			}

			if !User.isSignedIn {
				self.cosmosView.rating = 0.0
			}
		}

		// Configure average rating
		self.ratingLabel.text = "\(episode.attributes.stats?.ratingAverage ?? 0.0)"

		// Configure rating count
		let ratingCount = episode.attributes.stats?.ratingCount ?? 0
		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}
}
