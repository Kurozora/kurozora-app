//
//  DestructiveActionCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class DestructiveActionCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.textAlignment = .center
		label.textColor = .systemRed
		return label
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
	/// Configures the cell with the destructive title.
	///
	/// - Parameter title: The title for the destructive row.
	func configure(title: String) {
		self.hideSkeleton()
		self.titleLabel.text = title
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12
	}

	private func configureSubviews() {
		self.contentView.addSubview(self.titleLabel)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
			self.titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
		])
	}
}
