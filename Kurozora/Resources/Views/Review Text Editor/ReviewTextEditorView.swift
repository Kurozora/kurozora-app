//
//  ReviewTextEditorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ReviewTextEditorViewDelegate: AnyObject {
	func reviewTextEditorView(_ view: ReviewTextEditorView, rateWith rating: Double)
	func reviewTextEditorView(_ view: ReviewTextEditorView, textDidChange text: String)
	func reviewTextEditorView(_ view: ReviewTextEditorView, noteDidChange note: String)
}

final class ReviewTextEditorView: UIView {
	// MARK: - IBOutlets
	@IBOutlet private weak var primaryLabel: KLabel!
	@IBOutlet private weak var cosmosView: KCosmosView!
	@IBOutlet private weak var textViewPlaceholder: UIView!

	// MARK: - Views
	private(set) var textView: KTextView!
	private(set) var noteTextView: KTextView!

	private lazy var emojiRatingView: EmojiRatingView = {
		let emojiRatingView = EmojiRatingView()
		emojiRatingView.delegate = self
		emojiRatingView.isHidden = true
		emojiRatingView.allowsDeselection = false
		emojiRatingView.translatesAutoresizingMaskIntoConstraints = false

		guard let ratingView = self.cosmosView.superview else { return emojiRatingView }
		ratingView.addSubview(emojiRatingView)

		NSLayoutConstraint.activate([
			emojiRatingView.leadingAnchor.constraint(equalTo: self.cosmosView.leadingAnchor),
			emojiRatingView.centerYAnchor.constraint(equalTo: self.cosmosView.centerYAnchor),
			ratingView.trailingAnchor.constraint(greaterThanOrEqualTo: emojiRatingView.trailingAnchor),
			emojiRatingView.heightAnchor.constraint(lessThanOrEqualTo: self.cosmosView.heightAnchor)
		])

		return emojiRatingView
	}()

	// MARK: - Properties
	public weak var delegate: ReviewTextEditorViewDelegate?

	// MARK: - XIB loaded
	override func awakeFromNib() {
		super.awakeFromNib()
		self.installTextViews()
		self.configure()
	}

	// MARK: - Display
	/// Updates the view with the given rating, review and note.
	///
	/// - Parameters:
	///    - rating: The rating to render, or `nil` when the item is unrated.
	///    - review: The text to render in the review field.
	///    - note: The text to render in the private note field.
	func configure(rating: Double?, review: String?, note: String?) {
		switch UserSettings.ratingStyle {
		case .quickReaction:
			self.cosmosView.isHidden = true
			self.emojiRatingView.isHidden = false
			self.emojiRatingView.configure(using: rating)
		default:
			self.cosmosView.isHidden = false
			self.emojiRatingView.isHidden = true

			let rating = rating ?? 0.0
			self.cosmosView.rating = rating > 0 ? rating : 1.0
		}

		self.textView.text = review
		self.noteTextView.text = note
	}
}

// MARK: - Configuration
private extension ReviewTextEditorView {
	func installTextViews() {
		let reviewInputView = TitledTextView(title: nil, placeholder: L10n.whatsOnYourMind)
		let noteInputView = TitledTextView(title: nil, placeholder: L10n.whatsOnYourMind)
		let separatorView = SeparatorView()

		let reviewSectionView = UIStackView(arrangedSubviews: [self.makeSectionLabel(L10n.review), reviewInputView])
		reviewSectionView.axis = .vertical
		reviewSectionView.spacing = 8

		let noteSectionView = UIStackView(arrangedSubviews: [self.makeSectionLabel(L10n.privateNotes), noteInputView])
		noteSectionView.axis = .vertical
		noteSectionView.spacing = 8

		let stackView = UIStackView(arrangedSubviews: [reviewSectionView, separatorView, noteSectionView])
		stackView.axis = .vertical
		stackView.spacing = 20
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.textViewPlaceholder.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.textViewPlaceholder.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.textViewPlaceholder.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.textViewPlaceholder.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.textViewPlaceholder.bottomAnchor, constant: -20),

			separatorView.heightAnchor.constraint(equalToConstant: 1.0),
			noteInputView.heightAnchor.constraint(equalTo: reviewInputView.heightAnchor)
		])

		self.textView = reviewInputView.textView
		self.noteTextView = noteInputView.textView
	}

	func makeSectionLabel(_ title: String) -> KLabel {
		let label = KLabel()
		label.text = title
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.adjustsFontForContentSizeCategory = true
		return label
	}

	func configure() {
		self.configureViews()
	}

	// MARK: - View configuration
	func configureViews() {
		self.configureView()
		self.configurePrimaryLabel()
		self.configureCosmosView()
		self.configureTextViews()
	}

	func configureView() {}

	func configurePrimaryLabel() {
		self.primaryLabel.text = UIDevice.isPhone || UIDevice.isPad ? L10n.tapToRate : L10n.clickToRate
	}

	func configureCosmosView() {
		self.cosmosView.settings.starSize = 20
		self.cosmosView.settings.fillMode = .half
		self.cosmosView.settings.minTouchRating = 0.5
		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			self.delegate?.reviewTextEditorView(self, rateWith: rating)
		}
	}

	func configureTextViews() {
		self.textView.delegate = self
		self.noteTextView.delegate = self
	}
}

// MARK: - UITextViewDelegate
extension ReviewTextEditorView: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		if textView === self.noteTextView {
			self.delegate?.reviewTextEditorView(self, noteDidChange: textView.text)
		} else {
			self.delegate?.reviewTextEditorView(self, textDidChange: textView.text)
		}
	}
}

// MARK: - EmojiRatingViewDelegate
extension ReviewTextEditorView: EmojiRatingViewDelegate {
	func emojiRatingView(_ emojiRatingView: EmojiRatingView, rateWith rating: Double) {
		self.delegate?.reviewTextEditorView(self, rateWith: rating)
	}
}
