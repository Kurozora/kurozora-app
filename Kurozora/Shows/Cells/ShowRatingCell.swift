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

	var showDetails: ShowDetails? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let showDetails = showDetails else { return }

		// Configure cosmos view
		if let userRating = showDetails.userProfile?.currentRating {
			self.cosmosView.rating = userRating
		}

		cosmosView.didFinishTouchingCosmos = { rating in
			self.rateShow(with: rating)
        }

		// Configure average rating
		if let averageRating = showDetails.showDetailsElement?.averageRating {
			ratingLabel.text = "\(averageRating)"
		}

		// Configure rating count
		if let ratingCount = showDetails.showDetailsElement?.ratingCount {
			cosmosDetailLabel.text = ratingCount != 0 ? "\(ratingCount) Ratings" : "Not enough ratings"
		}
	}

	/**
		Rate the show with the given rating.

		- Parameter rating: The rating to be saved when the show has been rated by the user.
	*/
	func rateShow(with rating: Double) {
		guard let showDetails = showDetails else { return }
		guard let showID = showDetails.showDetailsElement?.id else { return }

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
