//
//  KotodamaDistributionCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaDistributionCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let guessCountLabel = UILabel()
	private let trackView = UIView()
	private let fillView = UIView()
	private let winsLabel = UILabel()

	// MARK: - Properties
	private var fillWidthConstraint: NSLayoutConstraint!

	/// The percentage the fill constraint was last built for.
	private var fillPercent: Int = 0

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
		self.guessCountLabel.translatesAutoresizingMaskIntoConstraints = false
		self.guessCountLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
		self.guessCountLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.contentView.addSubview(self.guessCountLabel)

		self.trackView.translatesAutoresizingMaskIntoConstraints = false
		self.trackView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.trackView.layer.cornerCurve = .continuous
		self.trackView.layer.cornerRadius = 4
		self.trackView.clipsToBounds = true
		self.contentView.addSubview(self.trackView)

		self.fillView.translatesAutoresizingMaskIntoConstraints = false
		self.fillView.theme_backgroundColor = KThemePicker.tintColor.rawValue
		self.trackView.addSubview(self.fillView)

		self.winsLabel.translatesAutoresizingMaskIntoConstraints = false
		self.winsLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
		self.winsLabel.textAlignment = .right
		self.winsLabel.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
		self.trackView.addSubview(self.winsLabel)

		self.fillWidthConstraint = self.fillView.widthAnchor.constraint(equalTo: self.trackView.widthAnchor, multiplier: 0)

		NSLayoutConstraint.activate([
			self.guessCountLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.guessCountLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.guessCountLabel.widthAnchor.constraint(equalToConstant: 16),
			self.trackView.leadingAnchor.constraint(equalTo: self.guessCountLabel.trailingAnchor, constant: 8),
			self.trackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.trackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.trackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.trackView.heightAnchor.constraint(equalToConstant: 20),
			self.fillView.leadingAnchor.constraint(equalTo: self.trackView.leadingAnchor),
			self.fillView.topAnchor.constraint(equalTo: self.trackView.topAnchor),
			self.fillView.bottomAnchor.constraint(equalTo: self.trackView.bottomAnchor),
			self.fillWidthConstraint,
			self.winsLabel.trailingAnchor.constraint(equalTo: self.trackView.trailingAnchor, constant: -8),
			self.winsLabel.centerYAnchor.constraint(equalTo: self.trackView.centerYAnchor)
		])
	}

	/// Configures the cell with one bucket.
	///
	/// - Parameter bar: The bucket to show.
	func configure(using bar: KotodamaDistributionBar) {
		self.guessCountLabel.text = "\(bar.guessCount)"
		self.winsLabel.text = "\(bar.wins)"

		self.updateFillWidth(percent: bar.percent)
	}

	/// Sizes the fill against the track using a multiplier constraint.
	///
	/// The applied percentage is tracked separately because UIKit normalizes a zero-multiplier
	/// anchor constraint into a constant, whose `multiplier` property reads `1.0`.
	///
	/// - Parameter percent: The share of the track to fill, between `0` and `100`.
	private func updateFillWidth(percent: Int) {
		guard percent != self.fillPercent else { return }

		self.fillPercent = percent
		self.fillWidthConstraint.isActive = false
		self.fillWidthConstraint = self.fillView.widthAnchor.constraint(
			equalTo: self.trackView.widthAnchor,
			multiplier: CGFloat(percent) / 100
		)
		self.fillWidthConstraint.isActive = true
	}
}
