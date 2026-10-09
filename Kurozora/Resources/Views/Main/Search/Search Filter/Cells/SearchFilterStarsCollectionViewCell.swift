//
//  SearchFilterStarsCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterStarsCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - Views
	private let titleLabel = KLabel()
	private let cosmosView = KCosmosView()
	private let separatorView = SeparatorView()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.configureViews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.configureViews()
	}

	// MARK: - Functions
	override func sharedInit() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 10.0
		self.contentView.layer.cornerCurve = .continuous
	}

	/// Builds the cell's view hierarchy.
	private func configureViews() {
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.numberOfLines = 0
		self.titleLabel.font = .preferredFont(forTextStyle: .body)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

		self.cosmosView.translatesAutoresizingMaskIntoConstraints = false
		self.cosmosView.settings.starSize = 24.0
		self.cosmosView.settings.updateOnTouch = true
		self.cosmosView.settings.fillMode = .half
		self.cosmosView.settings.minTouchRating = 0.5
		self.cosmosView.settings.disablePanGestures = true
		self.cosmosView.setContentHuggingPriority(.required, for: .horizontal)
		self.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self else { return }

			self.delegate?.searchFilterBaseCollectionViewCell(self, didChangeValue: rating)
		}

		self.separatorView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.cosmosView)
		self.contentView.addSubview(self.separatorView)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14.0),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -14.0),

			self.cosmosView.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 12.0),
			self.cosmosView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),
			self.cosmosView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

			self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		])
	}

	/// Configures the cell with the given title and rating.
	///
	/// - Parameters:
	///    - title: The name of the filter.
	///    - rating: The rating the user has chosen.
	///    - position: Where the row sits within its card.
	func configureCell(title: String, rating: Double?, position: GroupedRowPosition) {
		self.titleLabel.text = title
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue

		self.cosmosView.rating = rating ?? 0.0

		self.separatorView.isHidden = position == .last || position == .only
		self.contentView.layer.maskedCorners = position.maskedCorners
	}
}
