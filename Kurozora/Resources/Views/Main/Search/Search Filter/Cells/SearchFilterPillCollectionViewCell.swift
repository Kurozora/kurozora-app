//
//  SearchFilterPillCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class SearchFilterPillCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel = KLabel()
	private let subtitleLabel = KLabel()
	private let stackView = UIStackView()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.contentView.layerCornerRadius = self.contentView.bounds.height / 2.0
	}

	// MARK: - Functions
	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.titleLabel.textAlignment = .center
		self.titleLabel.numberOfLines = 0
		self.titleLabel.font = .preferredFont(forTextStyle: .headline)
		self.titleLabel.adjustsFontForContentSizeCategory = true

		self.subtitleLabel.textAlignment = .center
		self.subtitleLabel.numberOfLines = 0
		self.subtitleLabel.font = .preferredFont(forTextStyle: .caption2)
		self.subtitleLabel.adjustsFontForContentSizeCategory = true

		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.axis = .vertical
		self.stackView.alignment = .center
		self.stackView.spacing = 2.0
		self.stackView.addArrangedSubview(self.titleLabel)
		self.stackView.addArrangedSubview(self.subtitleLabel)

		self.contentView.addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.0),
			self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),
			self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.0)
		])
	}

	/// Configures the cell with the given title, detail and state.
	///
	/// - Parameters:
	///    - title: The name of the choice.
	///    - subtitle: The detail shown under the name.
	///    - state: The state the choice is in.
	func configureCell(title: String, subtitle: String?, state: FilterSelectionState) {
		self.subtitleLabel.text = subtitle
		self.subtitleLabel.isHidden = subtitle == nil

		switch state {
		case .neutral:
			self.titleLabel.attributedText = NSAttributedString(string: title)
			self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
			self.subtitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
			self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		case .included:
			self.titleLabel.attributedText = NSAttributedString(string: title)
			self.titleLabel.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
			self.subtitleLabel.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
			self.contentView.theme_backgroundColor = KThemePicker.tintColor.rawValue
		case .excluded:
			self.titleLabel.attributedText = NSAttributedString(string: title, attributes: [
				.strikethroughStyle: NSUnderlineStyle.single.rawValue
			])
			self.titleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
			self.subtitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
			self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
}
