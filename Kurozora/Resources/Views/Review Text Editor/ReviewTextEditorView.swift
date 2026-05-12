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
}

final class ReviewTextEditorView: UIView {
	// MARK: - IBOutlets
	@IBOutlet private weak var primaryLabel: KLabel!
	@IBOutlet private weak var cosmosView: KCosmosView!
	@IBOutlet private weak var textViewPlaceholder: UIView!

	// MARK: - Views
	private(set) var textView: KTextView!

	// MARK: - Properties
	public weak var delegate: ReviewTextEditorViewDelegate?

	// MARK: - XIB loaded
	override func awakeFromNib() {
		super.awakeFromNib()
		self.installTextView()
		self.configure()
	}

	// MARK: - Display
	/// Updates the view with the given rating and review.
	///
	/// - Parameters:
	///    - rating: The rating to render in the cosmos view.
	///    - review: The text to render in the review field.
	func configure(rating: Double, review: String?) {
		self.cosmosView.rating = rating
		self.textView.text = review
	}
}

// MARK: - Configuration
private extension ReviewTextEditorView {
	func installTextView() {
		let textView = KTextView()
		textView.alwaysBounceVertical = true
		textView.showsHorizontalScrollIndicator = false

		self.textViewPlaceholder.addSubview(textView)
		textView.fillToSuperview()

		self.textView = textView
	}

	func configure() {
		self.configureViews()
	}

	// MARK: - View configuration
	func configureViews() {
		self.configureView()
		self.configurePrimaryLabel()
		self.configureCosmosView()
		self.configureTextView()
	}

	func configureView() {}

	func configurePrimaryLabel() {
		self.primaryLabel.text = UIDevice.isPhone || UIDevice.isPad ? L10n.tapToRate : L10n.clickToRate
	}

	func configureCosmosView() {
		self.cosmosView.settings.starSize = 20
		self.cosmosView.settings.fillMode = .half
		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			self.delegate?.reviewTextEditorView(self, rateWith: rating)
		}
	}

	func configureTextView() {
		self.textView.placeholder = L10n.whatsOnYourMind
		self.textView.delegate = self
	}
}

// MARK: - UITextViewDelegate
extension ReviewTextEditorView: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.delegate?.reviewTextEditorView(self, textDidChange: textView.text)
	}
}
