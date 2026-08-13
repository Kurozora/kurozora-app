//
//  ReasonTextCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol ReasonTextCollectionViewCellDelegate: AnyObject {
	func reasonTextCollectionViewCell(_ cell: ReasonTextCollectionViewCell, didChange text: String)
}

class ReasonTextCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	let textView: KTextView = {
		let view = KTextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isScrollEnabled = false
		view.font = .preferredFont(forTextStyle: .body)
		view.placeholder = L10n.parentalGuideReasonPlaceholder
		view.backgroundColor = .clear
		view.textContainerInset = .zero
		view.textContainer.lineFragmentPadding = 0
		return view
	}()

	private let counterLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption2)
		label.textAlignment = .right
		return label
	}()

	// MARK: - Properties
	weak var delegate: ReasonTextCollectionViewCellDelegate?

	private let characterLimit = 500

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
	/// Configures the cell with the existing reason text.
	///
	/// - Parameters:
	///    - text: The current reason text.
	///    - delegate: The delegate that receives edit events.
	func configure(text: String, delegate: ReasonTextCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.delegate = delegate
		self.textView.text = text
		self.updateCounter(for: text)
	}

	private func configureSubviews() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.textView.delegate = self

		self.contentView.addSubview(self.textView)
		self.contentView.addSubview(self.counterLabel)

		NSLayoutConstraint.activate([
			self.textView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.textView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
			self.textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

			self.counterLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.counterLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.counterLabel.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 8),
			self.counterLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12)
		])
	}

	private func updateCounter(for text: String) {
		self.counterLabel.text = "\(text.count) / \(self.characterLimit)"
	}
}

// MARK: - UITextViewDelegate
extension ReasonTextCollectionViewCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		let trimmed = String(textView.text.prefix(self.characterLimit))
		if textView.text != trimmed {
			textView.text = trimmed
		}

		self.updateCounter(for: trimmed)
		self.delegate?.reasonTextCollectionViewCell(self, didChange: trimmed)
	}
}
