//
//  ReportDetailsTextCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol ReportDetailsTextCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the details text changed.
	///
	/// - Parameters:
	///    - cell: The cell whose text changed.
	///    - text: The new text.
	func reportDetailsTextCollectionViewCell(_ cell: ReportDetailsTextCollectionViewCell, didChange text: String)
}

class ReportDetailsTextCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	let textView: KTextView = {
		let view = KTextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isScrollEnabled = false
		view.font = .preferredFont(forTextStyle: .body)
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
	weak var delegate: ReportDetailsTextCollectionViewCellDelegate?

	private let characterLimit = 1000

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
	/// Configures the cell.
	///
	/// - Parameters:
	///    - text: The current details text.
	///    - placeholder: The placeholder shown when the text is empty.
	///    - delegate: The delegate that receives edit events.
	func configure(text: String, placeholder: String, delegate: ReportDetailsTextCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.delegate = delegate
		self.textView.placeholder = placeholder
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
extension ReportDetailsTextCollectionViewCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		let trimmed = String(textView.text.prefix(self.characterLimit))

		if textView.text != trimmed {
			textView.text = trimmed
		}

		self.updateCounter(for: trimmed)
		self.delegate?.reportDetailsTextCollectionViewCell(self, didChange: trimmed)
	}
}
