//
//  KotodamaMenuRowView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaMenuRowView: UIView {
	// MARK: - Views
	private let symbolImageView = UIImageView()
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let chevronImageView = UIImageView()

	// MARK: - Properties
	/// Whether the row is being pressed.
	var isHighlighted: Bool = false {
		didSet {
			self.applySelectionState()
		}
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

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.layer.cornerCurve = .continuous
		self.layer.cornerRadius = 12

		self.symbolImageView.translatesAutoresizingMaskIntoConstraints = false
		self.symbolImageView.contentMode = .scaleAspectFit
		self.addSubview(self.symbolImageView)

		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.font = .preferredFont(forTextStyle: .headline)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.addSubview(self.titleLabel)

		self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
		self.subtitleLabel.adjustsFontForContentSizeCategory = true
		self.subtitleLabel.numberOfLines = 2
		self.addSubview(self.subtitleLabel)

		self.chevronImageView.translatesAutoresizingMaskIntoConstraints = false
		self.chevronImageView.contentMode = .scaleAspectFit
		self.chevronImageView.image = UIImage(systemName: "chevron.forward")
		self.addSubview(self.chevronImageView)

		NSLayoutConstraint.activate([
			self.symbolImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
			self.symbolImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.symbolImageView.widthAnchor.constraint(equalToConstant: 24),
			self.symbolImageView.heightAnchor.constraint(equalToConstant: 24),
			self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.symbolImageView.trailingAnchor, constant: 12),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.chevronImageView.leadingAnchor, constant: -8),
			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2),
			self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
			self.subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
			self.chevronImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
			self.chevronImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.chevronImageView.widthAnchor.constraint(equalToConstant: 12)
		])

		self.applySelectionState()
	}

	/// Configures the row with the given content.
	///
	/// - Parameters:
	///    - symbolName: The name of the symbol shown at the leading edge.
	///    - title: The title of the row.
	///    - subtitle: The description of the row.
	func configure(symbolName: String, title: String, subtitle: String) {
		self.symbolImageView.image = UIImage(systemName: symbolName)
		self.titleLabel.text = title
		self.subtitleLabel.text = subtitle
		self.accessibilityLabel = title
		self.accessibilityHint = subtitle
	}

	/// Applies the colors of the row's current selection state.
	private func applySelectionState() {
		if self.isHighlighted {
			self.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			self.titleLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			self.subtitleLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			self.chevronImageView.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue
			self.symbolImageView.theme_tintColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			return
		}

		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		self.subtitleLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		self.chevronImageView.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue
		self.symbolImageView.theme_tintColor = KThemePicker.tintColor.rawValue
	}
}
