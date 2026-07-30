//
//  KotodamaHeadingCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaHeadingCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let textLabel = UILabel()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the cell.
	private func sharedInit() {
		self.textLabel.translatesAutoresizingMaskIntoConstraints = false
		self.textLabel.numberOfLines = 0
		self.textLabel.adjustsFontForContentSizeCategory = true
		self.contentView.addSubview(self.textLabel)

		NSLayoutConstraint.activate([
			self.textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
		])
	}

	/// Configures the cell with the given text.
	///
	/// - Parameter heading: The text to show.
	func configure(using heading: KotodamaHeading) {
		self.textLabel.text = heading.text

		if heading.isProminent {
			self.textLabel.font = .preferredFont(forTextStyle: .headline)
			self.textLabel.theme_textColor = KThemePicker.textColor.rawValue
			return
		}

		self.textLabel.font = .preferredFont(forTextStyle: .footnote)
		self.textLabel.theme_textColor = KThemePicker.subTextColor.rawValue
	}
}
