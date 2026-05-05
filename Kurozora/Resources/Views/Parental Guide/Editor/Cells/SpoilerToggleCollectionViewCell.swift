//
//  SpoilerToggleCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol SpoilerToggleCollectionViewCellDelegate: AnyObject {
	func spoilerToggleCollectionViewCell(_ cell: SpoilerToggleCollectionViewCell, didSet isOn: Bool)
}

class SpoilerToggleCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = L10n.parentalGuideSpoiler
		label.numberOfLines = 0
		return label
	}()

	private let toggle: KSwitch = {
		let toggle = KSwitch()
		toggle.translatesAutoresizingMaskIntoConstraints = false
		return toggle
	}()

	// MARK: - Properties
	weak var delegate: SpoilerToggleCollectionViewCellDelegate?

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
	/// Configures the cell with the spoiler toggle state.
	///
	/// - Parameters:
	///    - isOn: Whether the toggle should be on.
	///    - delegate: The delegate that receives change events.
	func configure(isOn: Bool, delegate: SpoilerToggleCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.delegate = delegate
		self.toggle.isOn = isOn
	}

	private func configureSubviews() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.toggle)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),

			self.toggle.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 12),
			self.toggle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.toggle.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor)
		])

		self.toggle.addTarget(self, action: #selector(self.toggleChanged), for: .valueChanged)
	}

	@objc private func toggleChanged() {
		self.delegate?.spoilerToggleCollectionViewCell(self, didSet: self.toggle.isOn)
	}
}
