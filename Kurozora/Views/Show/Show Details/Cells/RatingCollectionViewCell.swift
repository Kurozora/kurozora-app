//
//  RatingCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RatingCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var cosmosDetailLabel: KSecondaryLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet weak var ratingDetailLabel: KSecondaryLabel!

	// MARK: - Properties
	var show: Show! {
		didSet {
			configureCell()
		}
	}
	var episode: Episode! {
		didSet {
			configureEpisodeCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		// Configure cosmos view
		let userRating = self.show.attributes.givenRating
		self.cosmosView.rating = userRating ?? 0.0

		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			WorkflowController.shared.isSignedIn {
				self.rateShow(with: rating)
			}

			if !User.isSignedIn {
				self.cosmosView.rating = 0.0
			}
        }

		// Configure average rating
		self.ratingLabel.text = "\(self.show.attributes.stats?.ratingAverage ?? 0.0)"

		// Configure rating count
		let ratingCount = self.show.attributes.stats?.ratingCount ?? 0
		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}

	/// Configure the cell with the episode details.
	fileprivate func configureEpisodeCell() {
		// Configure cosmos view
		let userRating = self.episode.attributes.givenRating
		self.cosmosView.rating = userRating ?? 0.0

		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			WorkflowController.shared.isSignedIn {
				self.rateEpisode(with: rating)
			}

			if !User.isSignedIn {
				self.cosmosView.rating = 0.0
			}
		}

		// Configure average rating
		self.ratingLabel.text = "\(self.episode.attributes.stats?.ratingAverage ?? 0.0)"

		// Configure rating count
		let ratingCount = self.episode.attributes.stats?.ratingCount ?? 0
		self.cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
	}

	/// Rate the show with the given rating.
	///
	/// - Parameter rating: The rating to be saved when the show has been rated by the user.
	func rateShow(with rating: Double) {
		KService.rateShow(self.show.id, with: rating, description: nil) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success:
				// Update current rating for the user.
				self.show.attributes.givenRating = rating

				// Show a success alert thanking the user for rating.
				let alertController = UIApplication.topViewController?.presentAlertController(title: "Rating Submitted", message: "Thank you for rating.")

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
					alertController?.dismiss(animated: true, completion: nil)
				}
			case .failure: break
			}
		}
	}

	/// Rate the show with the given rating.
	///
	/// - Parameter rating: The rating to be saved when the show has been rated by the user.
	func rateEpisode(with rating: Double) {
		KService.rateEpisode(self.episode.id, with: rating, description: nil) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success:
				// Update current rating for the user.
				self.episode.attributes.givenRating = rating

				// Show a success alert thanking the user for rating.
				let alertController = UIApplication.topViewController?.presentAlertController(title: "Rating Submitted", message: "Thank you for rating.")

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
					alertController?.dismiss(animated: true, completion: nil)
				}
			case .failure: break
			}
		}
	}
}
