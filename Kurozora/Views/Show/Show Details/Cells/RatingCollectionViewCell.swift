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

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		// Configure cosmos view
		let userRating = self.show.attributes.givenRating
		self.cosmosView.rating = userRating ?? 0.0

		cosmosView.didFinishTouchingCosmos = { rating in
			WorkflowController.shared.isSignedIn {
				self.rateShow(with: rating)
			}

			if !User.isSignedIn {
				self.cosmosView.rating = 0.0
			}
        }

		// Configure average rating
		ratingLabel.text = "\(show.attributes.stats?.ratingAverage ?? 0.0)"

		// Configure rating count
		let ratingCount = show.attributes.stats?.ratingCount ?? 0
		cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount) Ratings" : "Not enough ratings"
	}

	/**
		Rate the show with the given rating.

		- Parameter rating: The rating to be saved when the show has been rated by the user.
	*/
	func rateShow(with rating: Double) {
		KService.rateShow(self.show.id, with: rating) { result in
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
}
