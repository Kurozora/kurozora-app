//
//  KotodamaArchiveCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaArchiveCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let puzzleNumberLabel = UILabel()
	private let dateLabel = UILabel()
	private let solvedLabel = UILabel()

	// MARK: - Properties
	override var isHighlighted: Bool {
		didSet {
			self.contentView.theme_backgroundColor = self.isHighlighted
				? KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
				: KThemePicker.tableViewCellBackgroundColor.rawValue
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
	/// The shared init of the cell.
	private func sharedInit() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layer.cornerCurve = .continuous
		self.contentView.layer.cornerRadius = 8
		self.contentView.layer.borderWidth = 1
		self.contentView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker

		self.puzzleNumberLabel.translatesAutoresizingMaskIntoConstraints = false
		self.puzzleNumberLabel.textAlignment = .center
		self.puzzleNumberLabel.font = .preferredFont(forTextStyle: .caption1)
		self.puzzleNumberLabel.adjustsFontForContentSizeCategory = true
		self.puzzleNumberLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		self.contentView.addSubview(self.puzzleNumberLabel)

		self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
		self.dateLabel.textAlignment = .center
		self.dateLabel.numberOfLines = 2
		self.dateLabel.font = .preferredFont(forTextStyle: .subheadline).semibold
		self.dateLabel.adjustsFontForContentSizeCategory = true
		self.dateLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		self.contentView.addSubview(self.dateLabel)

		self.solvedLabel.translatesAutoresizingMaskIntoConstraints = false
		self.solvedLabel.textAlignment = .center
		self.solvedLabel.font = .preferredFont(forTextStyle: .caption1)
		self.solvedLabel.adjustsFontForContentSizeCategory = true
		self.contentView.addSubview(self.solvedLabel)

		NSLayoutConstraint.activate([
			self.puzzleNumberLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.puzzleNumberLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.puzzleNumberLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 12),
			self.puzzleNumberLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -12),
			self.dateLabel.topAnchor.constraint(equalTo: self.puzzleNumberLabel.bottomAnchor, constant: 4),
			self.dateLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 12),
			self.dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -12),
			self.solvedLabel.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 4),
			self.solvedLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.solvedLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12)
		])
	}

	/// Configures the cell with an archive entry.
	///
	/// - Parameters:
	///    - entry: The entry to show.
	///    - date: The parsed date of the entry.
	func configure(using entry: KotodamaArchiveEntry, date: Date?) {
		self.puzzleNumberLabel.text = "#\(entry.attributes.puzzleNumber)"
		self.dateLabel.text = date.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }

		if entry.attributes.isSolved {
			self.solvedLabel.text = L10n.kotodamaSolvedBadge
			self.solvedLabel.theme_textColor = KThemePicker.tintColor.rawValue
			self.solvedLabel.isHidden = false
		} else if entry.attributes.isFinished == true {
			self.solvedLabel.text = L10n.kotodamaPlayed
			self.solvedLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			self.solvedLabel.isHidden = false
		} else {
			self.solvedLabel.isHidden = true
		}
	}
}
