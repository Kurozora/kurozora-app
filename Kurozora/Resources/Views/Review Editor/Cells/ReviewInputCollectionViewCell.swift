//
//  ReviewInputCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol ReviewInputCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the user edited the input.
	func reviewInputCollectionViewCell(_ cell: ReviewInputCollectionViewCell, didChangeText text: String)
}

/// A cell that renders a titled text input.
final class ReviewInputCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let separatorView = SeparatorView()
	private let titleLabel = KLabel()
	private let titledTextView = TitledTextView(title: nil, placeholder: L10n.whatsOnYourMind, visibleLines: 6)

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: ReviewInputCollectionViewCellDelegate?

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
	/// Configures the cell with the given title and text.
	func configure(title: String, text: String?, showsSeparator: Bool) {
		self.separatorView.isHidden = !showsSeparator
		self.titleLabel.text = title
		self.titledTextView.textView.text = text
	}

	private func configureSubviews() {
		self.backgroundColor = .clear
		self.contentView.directionalLayoutMargins = .zero

		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.titleLabel.adjustsFontForContentSizeCategory = true

		self.titledTextView.textView.delegate = self

		let stackView = UIStackView(arrangedSubviews: [self.separatorView, self.titleLabel, self.titledTextView])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.setCustomSpacing(20, after: self.separatorView)
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

// MARK: - UITextViewDelegate
extension ReviewInputCollectionViewCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.delegate?.reviewInputCollectionViewCell(self, didChangeText: textView.text ?? "")
	}
}
