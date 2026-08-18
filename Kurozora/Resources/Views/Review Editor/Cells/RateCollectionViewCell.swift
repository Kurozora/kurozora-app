//
//  RateCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol RateCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the user picked a rating.
	func rateCollectionViewCell(_ cell: RateCollectionViewCell, rateWith rating: Double)
}

/// A cell that rates an item in the user's rating style.
final class RateCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let primaryLabel = KLabel()
	private let cosmosView = KCosmosView()
	private let emojiRatingView = EmojiRatingView()
	private let separatorView = SecondarySeparatorView()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: RateCollectionViewCellDelegate?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - Functions
	/// Configures the cell with the given rating.
	func configure(using rating: Double?) {
		switch UserSettings.ratingStyle {
		case .quickReaction:
			self.cosmosView.isHidden = true
			self.emojiRatingView.isHidden = false
			self.emojiRatingView.configure(using: rating)
		default:
			self.cosmosView.isHidden = false
			self.emojiRatingView.isHidden = true
			self.cosmosView.rating = rating ?? 0.0
		}
	}

	private func configureSubviews() {
		self.backgroundColor = .clear
		self.contentView.directionalLayoutMargins = .zero

		self.primaryLabel.text = UIDevice.isPhone || UIDevice.isPad ? L10n.tapToRate : L10n.clickToRate

		self.cosmosView.settings.starSize = 20
		self.cosmosView.settings.fillMode = .half
		self.cosmosView.settings.minTouchRating = 0.5
		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			self.delegate?.rateCollectionViewCell(self, rateWith: rating)
		}

		self.emojiRatingView.isHidden = true
		self.emojiRatingView.allowsDeselection = false
		self.emojiRatingView.delegate = self

		let ratingRowStackView = UIStackView(arrangedSubviews: [self.primaryLabel, self.cosmosView, self.emojiRatingView])
		ratingRowStackView.axis = .horizontal
		ratingRowStackView.alignment = .center
		ratingRowStackView.spacing = 8
		ratingRowStackView.translatesAutoresizingMaskIntoConstraints = false

		let ratingRowWrapperView = UIView()
		ratingRowWrapperView.translatesAutoresizingMaskIntoConstraints = false
		ratingRowWrapperView.addSubview(ratingRowStackView)

		let wrapperHeightConstraint = ratingRowWrapperView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layouts.rateAndReviewRowHeight)

		NSLayoutConstraint.activate([
			ratingRowStackView.centerXAnchor.constraint(equalTo: ratingRowWrapperView.centerXAnchor),
			ratingRowStackView.topAnchor.constraint(equalTo: ratingRowWrapperView.topAnchor),
			ratingRowStackView.bottomAnchor.constraint(equalTo: ratingRowWrapperView.bottomAnchor),
			ratingRowStackView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingRowWrapperView.leadingAnchor),
			ratingRowStackView.trailingAnchor.constraint(lessThanOrEqualTo: ratingRowWrapperView.trailingAnchor),
			wrapperHeightConstraint
		])

		let stackView = UIStackView(arrangedSubviews: [ratingRowWrapperView, self.separatorView])
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.spacing = 0
		stackView.setCustomSpacing(8, after: ratingRowWrapperView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

			self.separatorView.heightAnchor.constraint(equalToConstant: 1.0)
		])
	}
}

// MARK: - EmojiRatingViewDelegate
extension RateCollectionViewCell: EmojiRatingViewDelegate {
	func emojiRatingView(_ emojiRatingView: EmojiRatingView, rateWith rating: Double) {
		self.delegate?.rateCollectionViewCell(self, rateWith: rating)
	}
}
