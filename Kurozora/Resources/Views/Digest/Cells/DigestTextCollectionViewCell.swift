//
//  DigestTextCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A full-width cell that renders a single secondary caption of digest text.
class DigestTextCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let captionLabel = KSecondaryLabel()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureCell()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureCell()
	}

	// MARK: - Functions
	/// Configure the cell with the given text.
	///
	/// - Parameters:
	///    - text: The text to display.
	///    - alignment: The horizontal alignment of the text.
	func configure(using text: String, alignment: NSTextAlignment = .center) {
		self.captionLabel.text = text
		self.captionLabel.textAlignment = alignment
	}

	/// Builds the cell's view hierarchy and constraints.
	private func configureCell() {
		self.captionLabel.translatesAutoresizingMaskIntoConstraints = false
		self.captionLabel.numberOfLines = 0
		self.captionLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.captionLabel.adjustsFontForContentSizeCategory = true
		self.contentView.addSubview(self.captionLabel)

		NSLayoutConstraint.activate([
			self.captionLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.captionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.captionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.captionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
		])
	}
}
