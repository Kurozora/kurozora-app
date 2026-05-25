//
//  IssueTimeoutMenuCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class IssueTimeoutMenuCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.numberOfLines = 0
		return label
	}()

	let menuButton: KButton = {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configuration = .plain()
		button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
		button.configuration?.imagePadding = 4
		button.configuration?.imagePlacement = .trailing
		button.configuration?.image = UIImage(systemName: "chevron.up.chevron.down")
		button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .small)
		button.theme_tintColor = KThemePicker.subTextColor.rawValue
		button.contentHorizontalAlignment = .trailing
		button.showsMenuAsPrimaryAction = true
		return button
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
	/// Configures the cell with the given title, selection, and menu.
	///
	/// - Parameters:
	///    - title: The leading title of the row.
	///    - selectionTitle: The currently-selected value shown in the trailing menu button.
	///    - menu: The menu shown when the trailing button is tapped.
	func configure(title: String, selectionTitle: String, menu: UIMenu) {
		self.hideSkeleton()
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.titleLabel.text = title
		self.menuButton.setTitle(selectionTitle, for: .normal)
		self.menuButton.menu = menu
	}

	private func configureSubviews() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.menuButton)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),

			self.menuButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 16),
			self.menuButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.menuButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor)
		])
	}
}
