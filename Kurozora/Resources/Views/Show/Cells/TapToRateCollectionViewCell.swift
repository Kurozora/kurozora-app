//
//  TapToRateCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol TapToRateCollectionViewCellDelegate: AnyObject {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double)
}

class TapToRateCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var cosmosView: KCosmosView!

	// MARK: - Properties
	weak var delegate: TapToRateCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using givenRating: Double?) {
		// Configure primary label
		self.primaryLabel.text = UIDevice.isPhone || UIDevice.isPad ? Trans.tapToRate : Trans.clickToRate

		// Configure cosmos view
		self.cosmosView.rating = givenRating ?? 0.0

		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			Task {
				let signedIn = await WorkflowController.shared.isSignedIn()
				guard signedIn else {
					self.cosmosView.rating = 0.0
					return
				}

				self.delegate?.tapToRateCollectionViewCell(self, rateWith: rating)
			}
		}
	}
}
