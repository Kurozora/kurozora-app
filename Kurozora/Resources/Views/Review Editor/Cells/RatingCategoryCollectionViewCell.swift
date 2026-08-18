//
//  RatingCategoryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol RatingCategoryCollectionViewCellDelegate: AnyObject {
	func ratingCategoryCollectionViewCell(_ cell: RatingCategoryCollectionViewCell, didChangeScore score: Double)
	func ratingCategoryCollectionViewCell(_ cell: RatingCategoryCollectionViewCell, didChangeReview review: String)
}

/// A cell that scores a single rating category.
final class RatingCategoryCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let nameLabel = KLabel()
	private let scoreLabel = KSecondaryLabel()
	private let descriptionLabel = KSecondaryLabel()
	private let slider = UISlider()
	private let reviewInputView = TitledTextView(title: nil, placeholder: L10n.whatStandsOut)

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: RatingCategoryCollectionViewCellDelegate?

	/// The increment the score snaps to.
	private static let scoreStep: Float = 0.5

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
	/// Configures the cell with the given rating category.
	func configure(using ratingCategory: RatingCategory) {
		let score = ratingCategory.attributes.score ?? RatingCategory.Attributes.maximumScore / 2.0

		self.nameLabel.text = ratingCategory.attributes.name
		self.descriptionLabel.text = ratingCategory.attributes.description
		self.descriptionLabel.isHidden = ratingCategory.attributes.description?.isEmpty ?? true
		self.scoreLabel.text = L10n.scoreOutOfTen(ratingCategory.formattedScore)
		self.slider.value = Float(score)
		self.reviewInputView.textView.text = ratingCategory.attributes.review
	}

	private func configureSubviews() {
		self.backgroundColor = .clear
		self.contentView.directionalLayoutMargins = .zero

		self.nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.nameLabel.adjustsFontForContentSizeCategory = true

		self.scoreLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		self.scoreLabel.adjustsFontForContentSizeCategory = true
		self.scoreLabel.textAlignment = .right
		self.scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		self.descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		self.descriptionLabel.adjustsFontForContentSizeCategory = true
		self.descriptionLabel.numberOfLines = 0

		self.slider.minimumValue = Float(RatingCategory.Attributes.minimumScore)
		self.slider.maximumValue = Float(RatingCategory.Attributes.maximumScore)
		#if !targetEnvironment(macCatalyst)
		self.slider.minimumTrackTintColor = KThemePicker.tintColor.colorValue
		#endif
		self.slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)

		self.reviewInputView.textView.delegate = self

		let titleStackView = UIStackView(arrangedSubviews: [self.nameLabel, self.scoreLabel])
		titleStackView.axis = .horizontal
		titleStackView.alignment = .firstBaseline
		titleStackView.spacing = 8

		let stackView = UIStackView(arrangedSubviews: [titleStackView, self.descriptionLabel, self.slider, self.reviewInputView])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
		])
	}

	// MARK: - Actions
	@objc private func sliderValueChanged(_ sender: UISlider) {
		let step = Self.scoreStep
		let steppedValue = (sender.value / step).rounded() * step

		if steppedValue != sender.value {
			sender.value = steppedValue
		}

		let score = Double(steppedValue)
		self.scoreLabel.text = L10n.scoreOutOfTen(score.formatted(.number.precision(.fractionLength(1))))
		self.delegate?.ratingCategoryCollectionViewCell(self, didChangeScore: score)
	}
}

// MARK: - UITextViewDelegate
extension RatingCategoryCollectionViewCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.delegate?.ratingCategoryCollectionViewCell(self, didChangeReview: textView.text ?? "")
	}
}
