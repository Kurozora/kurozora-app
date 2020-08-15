//
//  RatingCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Cosmos
import SCLAlertView

class RatingCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: CosmosView!
	@IBOutlet weak var cosmosDetailLabel: UILabel! {
		didSet {
			cosmosDetailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet weak var ratingDetailLabel: UILabel! {
		didSet {
			ratingDetailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - Properties
	var show: Show! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
//		// Configure cosmos view
//		if let userRating = show.currentUser?.currentRating {
//			self.cosmosView.rating = userRating
//		}

		cosmosView.didFinishTouchingCosmos = { rating in
			WorkflowController.shared.isSignedIn {
				self.rateShow(with: rating)
			}

			if !User.isSignedIn {
				self.cosmosView.rating = 0.0
			}
        }

		// Configure average rating
		ratingLabel.text = "\(show.attributes.averageRating)"

		// Configure rating count
		let ratingCount = show.attributes.ratingCount
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
//				// Update current rating for the user.
//				self.show?.currentUser?.currentRating = rating

				// Show a success alert thanking the user for rating.
				let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
				let sclAlertView = SCLAlertView(appearance: appearance).showSuccess("Submitted", subTitle: "Thanks for your rating.")

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
					sclAlertView.close()
				}
			case .failure: break
			}
		}
	}
}
