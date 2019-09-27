//
//  ShowRatingCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Cosmos
import SCLAlertView

class ShowRatingCell: UITableViewCell {
	@IBOutlet weak var cosmosView: CosmosView!
	@IBOutlet weak var cosmosDetailLabel: UILabel! {
		didSet {
			cosmosDetailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ratingLabel: UILabel! {
		didSet {
			ratingLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var ratingDetailLabel: UILabel! {
		didSet {
			ratingDetailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	var showDetailsElement: ShowDetailsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let showDetailsElement = showDetailsElement else { return }

		// Configure cosmos view
		if let userRating = showDetailsElement.currentUser?.currentRating {
			self.cosmosView.rating = userRating
		}

		cosmosView.didFinishTouchingCosmos = { rating in
			WorkflowController.shared.isSignedIn {
				self.rateShow(with: rating)
			}
        }

		// Configure average rating
		if let averageRating = showDetailsElement.averageRating {
			ratingLabel.text = "\(averageRating)"
		}

		// Configure rating count
		if let ratingCount = showDetailsElement.ratingCount {
			cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount) Ratings" : "Not enough ratings"
		}
	}

	/**
		Rate the show with the given rating.

		- Parameter rating: The rating to be saved when the show has been rated by the user.
	*/
	func rateShow(with rating: Double) {
		guard let showID = showDetailsElement?.id else { return }

		Service.shared.rateShow(showID, with: rating, withSuccess: { (success) in
			if success {
				let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
				let sclAlertView = SCLAlertView(appearance: appearance).showSuccess("Submitted", subTitle: "Thanks for your rating.")

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					sclAlertView.close()
				}
			}
		})
	}
}
