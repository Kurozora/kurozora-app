//
//  RatingCategoryTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol RatingCategoryTableViewCellDelegate: AnyObject {
	func ratingCategoryTableViewCell(_ cell: RatingCategoryTableViewCell, didChangeScore score: Double)
	func ratingCategoryTableViewCell(_ cell: RatingCategoryTableViewCell, didChangeReview review: String)
}

class RatingCategoryTableViewCell: KTableViewCell {
	// MARK: - Views
	private let nameLabel = KLabel()
	private let scoreLabel = KSecondaryLabel()
	private let descriptionLabel = KSecondaryLabel()
	private let slider = UISlider()
	private let noteInputView = TitledTextView(title: nil, placeholder: L10n.whatsOnYourMind)

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: RatingCategoryTableViewCellDelegate?

	/// The increment the score snaps to.
	private static let scoreStep: Float = 0.5

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using ratingCategory: RatingCategory) {
		let score = ratingCategory.attributes.score ?? RatingCategory.Attributes.maximumScore / 2.0

		self.nameLabel.text = ratingCategory.attributes.name
		self.descriptionLabel.text = ratingCategory.attributes.description
		self.descriptionLabel.isHidden = ratingCategory.attributes.description?.isEmpty ?? true
		self.scoreLabel.text = L10n.scoreOutOfTen(ratingCategory.formattedScore)
		self.slider.value = Float(score)
		self.noteInputView.textView.text = ratingCategory.attributes.review
	}

	private func configureSubviews() {
		self.selectionStyle = .none
		self.backgroundColor = .clear
		self.contentView.theme_backgroundColor = nil
		self.contentView.backgroundColor = .clear
		self.contentView.directionalLayoutMargins.top = 12
		self.contentView.directionalLayoutMargins.bottom = 12

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

		self.noteInputView.textView.delegate = self

		let titleStackView = UIStackView(arrangedSubviews: [self.nameLabel, self.scoreLabel])
		titleStackView.axis = .horizontal
		titleStackView.alignment = .firstBaseline
		titleStackView.spacing = 8

		let stackView = UIStackView(arrangedSubviews: [titleStackView, self.descriptionLabel, self.slider, self.noteInputView])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor)
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
		self.delegate?.ratingCategoryTableViewCell(self, didChangeScore: score)
	}
}

// MARK: - UITextViewDelegate
extension RatingCategoryTableViewCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.delegate?.ratingCategoryTableViewCell(self, didChangeReview: textView.text ?? "")
	}
}
