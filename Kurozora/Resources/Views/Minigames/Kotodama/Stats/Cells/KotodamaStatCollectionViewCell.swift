//
//  KotodamaStatCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaStatCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let valueLabel = UILabel()
	private let titleLabel = UILabel()

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
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layer.cornerCurve = .continuous
		self.contentView.layer.cornerRadius = 4
		self.contentView.layer.borderWidth = 1
		self.contentView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker

		self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
		self.valueLabel.textAlignment = .center
		self.valueLabel.adjustsFontSizeToFitWidth = true
		self.valueLabel.minimumScaleFactor = 0.6
		self.valueLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .bold)
		self.valueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		self.contentView.addSubview(self.valueLabel)

		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.textAlignment = .center
		self.titleLabel.numberOfLines = 2
		self.titleLabel.font = .preferredFont(forTextStyle: .caption2)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.titleLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		self.contentView.addSubview(self.titleLabel)

		NSLayoutConstraint.activate([
			self.valueLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.valueLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
			self.valueLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
			self.titleLabel.topAnchor.constraint(equalTo: self.valueLabel.bottomAnchor, constant: 2),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.valueLabel.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.valueLabel.trailingAnchor),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12)
		])
	}

	/// Configures the cell with one value.
	///
	/// - Parameter stat: The value to show.
	func configure(using stat: KotodamaStat) {
		self.valueLabel.text = stat.value
		self.titleLabel.text = stat.title
	}
}
