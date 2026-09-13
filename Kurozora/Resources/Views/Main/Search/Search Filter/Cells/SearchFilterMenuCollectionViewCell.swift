//
//  SearchFilterMenuCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterMenuCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - Views
	private let titleLabel = KLabel()
	private let valueButton = KButton(type: .system)
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

		self.valueButton.translatesAutoresizingMaskIntoConstraints = false
		self.valueButton.showsMenuAsPrimaryAction = true
		self.valueButton.changesSelectionAsPrimaryAction = false
		self.valueButton.titleLabel?.adjustsFontForContentSizeCategory = true
		self.valueButton.setContentHuggingPriority(.required, for: .horizontal)

		self.separatorView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.valueButton)
		self.contentView.addSubview(self.separatorView)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14.0),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -14.0),

			self.valueButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 12.0),
			self.valueButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),
			self.valueButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

			self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		])
	}

	/// Configures the cell with the given title, value and menu.
	///
	/// - Parameters:
	///    - title: The name of the filter.
	///    - value: The choice the user has made.
	///    - menu: The choices the row offers.
	///    - position: Where the row sits within its card.
	func configureCell(title: String, value: String?, menu: UIMenu, position: GroupedRowPosition) {
		self.titleLabel.text = title
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue

		var configuration = UIButton.Configuration.plain()
		configuration.title = value ?? L10n.filterAny
		configuration.image = UIImage(systemName: "chevron.up.chevron.down")
		configuration.imagePlacement = .trailing
		configuration.imagePadding = 4.0
		configuration.contentInsets = .zero
		configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .footnote)
		self.valueButton.configuration = configuration
		self.valueButton.theme_tintColor = KThemePicker.tintColor.rawValue
		self.valueButton.menu = menu

		self.separatorView.isHidden = position == .last || position == .only
		self.contentView.layer.maskedCorners = position.maskedCorners
	}
}
