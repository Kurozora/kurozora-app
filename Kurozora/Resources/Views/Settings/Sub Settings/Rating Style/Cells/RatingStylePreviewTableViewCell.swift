//
//  RatingStylePreviewTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol RatingStylePreviewTableViewCellDelegate: AnyObject {
	/// Tells the delegate the cell's content size changed.
	func ratingStylePreviewTableViewCellDidChangeHeight(_ cell: RatingStylePreviewTableViewCell)
}

/// A live example of what rating with a given style looks like.
class RatingStylePreviewTableViewCell: KTableViewCell {
	// MARK: - Views
	private let contentStackView = UIStackView()
	private let emojiRatingView = EmojiRatingView()
	private let quipLabel = KLabel()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: RatingStylePreviewTableViewCellDelegate?

	/// The emoji scores in order of increasing sentiment.
	private let emojiScores: [EmojiScore] = [.disliked, .neutral, .liked]

	/// The scores of the categories shown in the detailed example.
	private let previewCategories: [(name: String, score: String)] = [
		(L10n.story, "8.5"),
		(L10n.characters, "7.0")
	]

	/// The space between an example and its caption.
	private static let captionSpacing: CGFloat = 16.0

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
	/// Configures the cell with the given rating style.
	func configure(using ratingStyle: RatingStyle) {
		self.contentStackView.arrangedSubviews.forEach { arrangedSubview in
			self.contentStackView.removeArrangedSubview(arrangedSubview)
			arrangedSubview.removeFromSuperview()
		}

		switch ratingStyle {
		case .quickReaction:
			self.configureQuickReactionPreview()
		case .standard:
			self.configureStandardPreview()
		case .detailed:
			self.configureDetailedPreview()
		}
	}

	private func configureQuickReactionPreview() {
		self.emojiRatingView.configure(using: nil)
		self.updateQuip()

		self.contentStackView.addArrangedSubview(self.makeLeadingRow(self.emojiRatingView))
		self.contentStackView.addArrangedSubview(self.quipLabel)

		let captionLabel = self.makeCaptionLabel(L10n.ratingStyleQuickReactionCaption)
		self.contentStackView.addArrangedSubview(captionLabel)
		self.contentStackView.setCustomSpacing(Self.captionSpacing, after: self.quipLabel)

		self.contentStackView.addArrangedSubview(self.makeCaptionLabel(L10n.emojiConversionIntro))
		self.contentStackView.setCustomSpacing(Self.captionSpacing, after: captionLabel)

		for emojiScore in self.emojiScores {
			self.contentStackView.addArrangedSubview(self.makeConversionRow(for: emojiScore))
		}
	}

	private func configureStandardPreview() {
		let cosmosView = KCosmosView()
		cosmosView.settings.starSize = 24
		cosmosView.settings.updateOnTouch = true
		cosmosView.settings.fillMode = .half
		cosmosView.settings.minTouchRating = 0.5
		cosmosView.rating = 3.5

		let cosmosRow = self.makeLeadingRow(cosmosView)
		self.contentStackView.addArrangedSubview(cosmosRow)
		self.contentStackView.addArrangedSubview(self.makeCaptionLabel(L10n.ratingStyleStandardCaption))
		self.contentStackView.setCustomSpacing(Self.captionSpacing, after: cosmosRow)
	}

	private func configureDetailedPreview() {
		for previewCategory in self.previewCategories {
			self.contentStackView.addArrangedSubview(self.makeCategoryRow(name: previewCategory.name, score: L10n.scoreOutOfTen(previewCategory.score)))
		}

		let andMoreRow = self.makeCategoryRow(name: L10n.andMore, score: nil)
		self.contentStackView.addArrangedSubview(andMoreRow)

		self.contentStackView.addArrangedSubview(self.makeCaptionLabel(L10n.ratingStyleDetailedCaption))
		self.contentStackView.setCustomSpacing(Self.captionSpacing, after: andMoreRow)
	}

	/// Returns a row pairing a category with its score.
	private func makeCategoryRow(name: String, score: String?) -> UIView {
		let nameLabel = KLabel()
		nameLabel.text = name
		nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		nameLabel.adjustsFontForContentSizeCategory = true

		let scoreLabel = KSecondaryLabel()
		scoreLabel.text = score
		scoreLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		scoreLabel.adjustsFontForContentSizeCategory = true
		scoreLabel.textAlignment = .right

		let rowStackView = UIStackView(arrangedSubviews: [nameLabel, scoreLabel])
		rowStackView.axis = .horizontal
		rowStackView.spacing = 8

		return rowStackView
	}

	private func configureSubviews() {
		self.selectionStyle = .none

		self.quipLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		self.quipLabel.adjustsFontForContentSizeCategory = true
		self.quipLabel.numberOfLines = 0
		self.quipLabel.theme_textColor = KThemePicker.tintColor.rawValue

		self.emojiRatingView.delegate = self
		self.emojiRatingView.requiresAuthentication = false

		self.contentStackView.axis = .vertical
		self.contentStackView.spacing = 8
		self.contentStackView.alignment = .fill
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(self.contentStackView)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor)
		])
	}

	/// Returns a row pairing an emoji with the stars it is stored as.
	private func makeConversionRow(for emojiScore: EmojiScore) -> UIView {
		let emojiLabel = KLabel()
		emojiLabel.text = emojiScore.emoji
		emojiLabel.font = .systemFont(ofSize: 17)
		emojiLabel.setContentHuggingPriority(.required, for: .horizontal)

		let cosmosView = KCosmosView()
		cosmosView.settings.starSize = 14
		cosmosView.settings.updateOnTouch = false
		cosmosView.settings.fillMode = .half
		cosmosView.rating = emojiScore.score
		cosmosView.setContentHuggingPriority(.required, for: .horizontal)

		let starsLabel = KSecondaryLabel()
		starsLabel.text = L10n.outOfFiveStars(emojiScore.formattedScore)
		starsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		starsLabel.adjustsFontForContentSizeCategory = true

		let rowStackView = UIStackView(arrangedSubviews: [emojiLabel, cosmosView, starsLabel])
		rowStackView.axis = .horizontal
		rowStackView.alignment = .center
		rowStackView.spacing = 8

		return self.makeLeadingRow(rowStackView)
	}

	/// Returns the given view pushed to the leading edge of its row.
	private func makeLeadingRow(_ view: UIView) -> UIView {
		view.setContentHuggingPriority(.required, for: .horizontal)
		view.setContentCompressionResistancePriority(.required, for: .horizontal)

		let spacerView = UIView()
		spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)

		let rowStackView = UIStackView(arrangedSubviews: [view, spacerView])
		rowStackView.axis = .horizontal
		return rowStackView
	}

	private func makeCaptionLabel(_ text: String) -> KSecondaryLabel {
		let label = KSecondaryLabel()
		label.text = text
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}

	/// Shows the quip belonging to the picked emoji.
	private func updateQuip() {
		switch self.emojiRatingView.selectedEmojiScore {
		case .disliked:
			self.quipLabel.text = L10n.emojiScoreDislikedQuip
		case .neutral:
			self.quipLabel.text = L10n.emojiScoreNeutralQuip
		case .liked:
			self.quipLabel.text = L10n.emojiScoreLikedQuip
		case .none:
			self.quipLabel.text = nil
		}

		self.quipLabel.isHidden = self.quipLabel.text == nil
	}
}

// MARK: - EmojiRatingViewDelegate
extension RatingStylePreviewTableViewCell: EmojiRatingViewDelegate {
	func emojiRatingView(_ emojiRatingView: EmojiRatingView, rateWith rating: Double) {
		self.updateQuip()
		self.delegate?.ratingStylePreviewTableViewCellDidChangeHeight(self)
	}
}
