//
//  ParentalGuideEmptyCategoryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class ParentalGuideEmptyCategoryCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let messageLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.numberOfLines = 0
		return label
	}()

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
	/// Renders the empty-state message as a tinted, underlined invitation.
	func configure() {
		let title = L10n.pgNoEvaluation
		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: KThemePicker.tintColor.colorValue,
			.underlineStyle: NSUnderlineStyle.single.rawValue,
			.font: UIFont.preferredFont(forTextStyle: .body)
		]
		self.messageLabel.attributedText = NSAttributedString(string: title, attributes: attributes)
	}

	private func configureSubviews() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layer.cornerRadius = 10
		self.contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		self.contentView.addSubview(self.messageLabel)

		NSLayoutConstraint.activate([
			self.messageLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.messageLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.messageLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.messageLabel.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
		])
	}
}
