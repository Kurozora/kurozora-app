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
	func tapToRateCollectionViewCellDidRequestDetailedReview(_ cell: TapToRateCollectionViewCell)
}

extension TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCellDidRequestDetailedReview(_ cell: TapToRateCollectionViewCell) {}
}

class TapToRateCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var cosmosView: KCosmosView!

	// MARK: - Properties
	weak var delegate: TapToRateCollectionViewCellDelegate?

	private lazy var emojiRatingView: EmojiRatingView = {
		let emojiRatingView = EmojiRatingView()
		emojiRatingView.delegate = self
		emojiRatingView.isHidden = true
		emojiRatingView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(emojiRatingView)

		NSLayoutConstraint.activate([
			emojiRatingView.trailingAnchor.constraint(equalTo: self.cosmosView.trailingAnchor),
			emojiRatingView.centerYAnchor.constraint(equalTo: self.cosmosView.centerYAnchor),
			emojiRatingView.leadingAnchor.constraint(greaterThanOrEqualTo: self.primaryLabel.trailingAnchor, constant: 8),
			emojiRatingView.heightAnchor.constraint(lessThanOrEqualTo: self.cosmosView.heightAnchor)
		])

		return emojiRatingView
	}()

	private lazy var detailedReviewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cosmosViewTapped))

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using givenRating: Double?) {
		self.primaryLabel.text = UIDevice.isPhone || UIDevice.isPad ? L10n.tapToRate : L10n.clickToRate

		switch UserSettings.ratingStyle {
		case .quickReaction:
			self.configureQuickReaction(using: givenRating)
		case .standard:
			self.configureStandard(using: givenRating)
		case .detailed:
			self.configureDetailed(using: givenRating)
		}
	}

	/// Configures the cell to rate with a single emoji.
	private func configureQuickReaction(using givenRating: Double?) {
		self.cosmosView.isHidden = true
		self.cosmosView.removeGestureRecognizer(self.detailedReviewTapGestureRecognizer)
		self.emojiRatingView.isHidden = false
		self.emojiRatingView.configure(using: givenRating)
	}

	/// Configures the cell to rate out of five stars.
	private func configureStandard(using givenRating: Double?) {
		self.cosmosView.isHidden = false
		self.cosmosView.removeGestureRecognizer(self.detailedReviewTapGestureRecognizer)
		self.emojiRatingView.isHidden = true

		self.cosmosView.settings.updateOnTouch = true
		self.cosmosView.settings.fillMode = .half
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

	/// Configures the cell to open the detailed review.
	private func configureDetailed(using givenRating: Double?) {
		self.cosmosView.isHidden = false
		self.emojiRatingView.isHidden = true

		self.cosmosView.settings.updateOnTouch = false
		self.cosmosView.settings.fillMode = .precise
		self.cosmosView.rating = givenRating ?? 0.0
		self.cosmosView.didFinishTouchingCosmos = nil

		self.cosmosView.removeGestureRecognizer(self.detailedReviewTapGestureRecognizer)
		self.cosmosView.addGestureRecognizer(self.detailedReviewTapGestureRecognizer)
		self.cosmosView.isUserInteractionEnabled = true
	}

	// MARK: - Actions
	@objc private func cosmosViewTapped() {
		self.delegate?.tapToRateCollectionViewCellDidRequestDetailedReview(self)
	}
}

// MARK: - EmojiRatingViewDelegate
extension TapToRateCollectionViewCell: EmojiRatingViewDelegate {
	func emojiRatingView(_ emojiRatingView: EmojiRatingView, rateWith rating: Double) {
		self.delegate?.tapToRateCollectionViewCell(self, rateWith: rating)
	}
}
