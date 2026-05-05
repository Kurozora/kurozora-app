//
//  ParentalGuideSummaryCardCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class ParentalGuideSummaryCardCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let stackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = 12
		stack.alignment = .fill
		return stack
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
	/// Renders the supplied bold:value rows into the card.
	///
	/// - Parameter rows: An ordered list of `(key, value)` pairs to render.
	func configure(rows: [(key: String, value: String)]) {
		self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for row in rows {
			self.stackView.addArrangedSubview(self.makeRow(key: row.key, value: row.value))
		}
	}

	private func configureSubviews() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layer.cornerRadius = 10
		self.contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		self.contentView.addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
		])
	}

	private func makeRow(key: String, value: String) -> UIView {
		let keyLabel = KLabel()
		keyLabel.font = .preferredFont(forTextStyle: .body).bold
		keyLabel.text = "\(key):"
		keyLabel.setContentHuggingPriority(.required, for: .horizontal)
		keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		let valueLabel = KSecondaryLabel()
		valueLabel.font = .preferredFont(forTextStyle: .body)
		valueLabel.numberOfLines = 0
		valueLabel.text = value

		let row = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
		row.axis = .horizontal
		row.alignment = .firstBaseline
		row.spacing = 6
		return row
	}
}
