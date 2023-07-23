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
	func ratingCollectionViewCell(rateWith rating: Double)
}

class RatingCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
//	@IBOutlet weak var cosmosView: KCosmosView!
//	@IBOutlet weak var cosmosDetailLabel: KSecondaryLabel!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	weak var delegate: RatingCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using show: Show) {
//		// Configure cosmos view
//		let userRating = show.attributes.givenRating
//		self.cosmosView.rating = userRating ?? 0.0

//		self.cosmosView.didFinishTouchingCosmos = { rating in
//			WorkflowController.shared.isSignedIn { [weak self] in
//				guard let self = self else { return }
//				self.delegate?.ratingCollectionViewCell(rateWith: rating)
//			}
//
//			if !User.isSignedIn {
//				self.cosmosView.rating = 0.0
//			}
//		}

		// Configure average rating
		self.primaryLabel.text = "\(show.attributes.stats?.ratingAverage ?? 0.0)"

//		// Configure rating count
//		let ratingCount = show.attributes.stats?.ratingCount ?? 0
//		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}

	/// Configure the cell with the given details.
	func configure(using literature: Literature) {
//		// Configure cosmos view
//		let userRating = literature.attributes.givenRating
//		self.cosmosView.rating = userRating ?? 0.0
//
//		self.cosmosView.didFinishTouchingCosmos = { rating in
//			WorkflowController.shared.isSignedIn { [weak self] in
//				guard let self = self else { return }
//				self.delegate?.ratingCollectionViewCell(rateWith: rating)
//			}
//
//			if !User.isSignedIn {
//				self.cosmosView.rating = 0.0
//			}
//		}

		// Configure average rating
		self.primaryLabel.text = "\(literature.attributes.stats?.ratingAverage ?? 0.0)"

//		// Configure rating count
//		let ratingCount = literature.attributes.stats?.ratingCount ?? 0
//		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}

	/// Configure the cell with the given details.
	func configure(using game: Game) {
//		// Configure cosmos view
//		let userRating = game.attributes.givenRating
//		self.cosmosView.rating = userRating ?? 0.0
//
//		self.cosmosView.didFinishTouchingCosmos = { rating in
//			WorkflowController.shared.isSignedIn { [weak self] in
//				guard let self = self else { return }
//				self.delegate?.ratingCollectionViewCell(rateWith: rating)
//			}
//
//			if !User.isSignedIn {
//				self.cosmosView.rating = 0.0
//			}
//		}

		// Configure average rating
		self.primaryLabel.text = "\(game.attributes.stats?.ratingAverage ?? 0.0)"

//		// Configure rating count
//		let ratingCount = game.attributes.stats?.ratingCount ?? 0
//		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}

	/// Configure the cell with the episode details.
	func configure(using episode: Episode) {
//		// Configure cosmos view
//		let userRating = episode.attributes.givenRating
//		self.cosmosView.rating = userRating ?? 0.0
//
//		self.cosmosView.didFinishTouchingCosmos = { rating in
//			WorkflowController.shared.isSignedIn { [weak self] in
//				guard let self = self else { return }
//				self.delegate?.ratingCollectionViewCell(rateWith: rating)
//			}
//
//			if !User.isSignedIn {
//				self.cosmosView.rating = 0.0
//			}
//		}

		// Configure average rating
		self.primaryLabel.text = "\(episode.attributes.stats?.ratingAverage ?? 0.0)"

//		// Configure rating count
//		let ratingCount = episode.attributes.stats?.ratingCount ?? 0
//		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}
}
