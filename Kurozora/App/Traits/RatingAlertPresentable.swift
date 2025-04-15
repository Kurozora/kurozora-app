//
//  RatingAlertPresentable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

@MainActor
protocol RatingAlertPresentable where Self: UIViewController {
	/// Show a success alert thanking the user for rating.
	func showRatingSuccessAlert()
	/// Show a failure alert informing the user that rating failed.
	///
	/// - Parameter message: The error message to display.
	func showRatingFailureAlert(message: String)
}

extension RatingAlertPresentable {
	func showRatingSuccessAlert() {
		let alertController = self.presentAlertController(
			title: Trans.submitted,
			message: Trans.thankYouForRating
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			alertController.dismiss(animated: true, completion: nil)
		}
	}

	func showRatingFailureAlert(message: String) {
		let alertController = self.presentAlertController(
			title: Trans.ratingFailed,
			message: message
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			alertController.dismiss(animated: true, completion: nil)
		}
	}
}
