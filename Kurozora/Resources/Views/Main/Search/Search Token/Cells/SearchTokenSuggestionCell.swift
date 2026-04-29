//
//  SearchTokenSuggestionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

final class SearchTokenSuggestionTableViewCell: KTableViewCell {
	// MARK: - Properties
	private let titleLabel = UILabel()

	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.configureViews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.configureViews()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.applyUnhighlightedAppearance()
	}

	// MARK: - Functions
	/// Updates the cell to display the given search type.
	///
	/// - Parameter type: The search type whose localized name should be rendered.
	func configure(with type: SearchType) {
		self.titleLabel.text = type.stringValue
	}

	/// Applies the cell's highlighted appearance.
	func applyHighlightedAppearance() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		self.titleLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
	}

	/// Restores the cell's resting appearance.
	func applyUnhighlightedAppearance() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
	}

	/// Builds the view hierarchy and applies the resting theme.
	private func configureViews() {
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.font = .preferredFont(forTextStyle: .body)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.contentView.addSubview(self.titleLabel)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
		])

		self.applyUnhighlightedAppearance()
	}
}
