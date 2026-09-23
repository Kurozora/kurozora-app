//
//  ReCapStatLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A card showing a habit or activity stat of a Re:CAP.
final class ReCapStatLockupCollectionViewCell: ReCapCardCollectionViewCell {
	// MARK: - Views
	private let titleLabel = UILabel()

	private let valueLabel = UILabel()

	private let captionLabel = UILabel()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
		self.titleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.titleLabel.numberOfLines = 2

		self.valueLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
		self.valueLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.valueLabel.numberOfLines = 2

		self.captionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.captionLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		let valueStackView = UIStackView(arrangedSubviews: [self.valueLabel, self.captionLabel])
		valueStackView.axis = .vertical
		valueStackView.spacing = 4.0

		let stackView = UIStackView(arrangedSubviews: [self.titleLabel, valueStackView])
		stackView.axis = .vertical
		stackView.distribution = .equalSpacing
		stackView.spacing = 24.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		self.cardView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 16.0),
			stackView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 16.0),
			stackView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -16.0),
			stackView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor, constant: -16.0),
		])
	}

	/// Configures the card with the given stat.
	///
	/// - Parameter statCard: The stat the card shows.
	func configure(using statCard: ReCapStatCard) {
		self.titleLabel.text = statCard.title
		self.valueLabel.text = statCard.value
		self.captionLabel.text = statCard.caption
		self.captionLabel.isHidden = statCard.caption == nil
	}
}
