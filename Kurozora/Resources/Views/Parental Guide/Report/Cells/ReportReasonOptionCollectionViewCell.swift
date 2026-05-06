//
//  ReportReasonOptionCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ReportReasonOptionCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.numberOfLines = 0
		return label
	}()

	private let checkmarkImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.theme_tintColor = KThemePicker.tintColor.rawValue
		imageView.contentMode = .scaleAspectFit
		imageView.isHidden = true
		return imageView
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
	/// Configures the cell for a reason option.
	///
	/// - Parameters:
	///    - reason: The reason this row represents.
	///    - isSelected: Whether this option is currently selected.
	func configure(using reason: ParentalGuideReportReason, isSelected: Bool) {
		self.hideSkeleton()
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.titleLabel.text = Self.displayTitle(for: reason)
		self.checkmarkImageView.isHidden = !isSelected
	}

	private func configureSubviews() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 12

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.checkmarkImageView)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),

			self.checkmarkImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 12),
			self.checkmarkImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.checkmarkImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
			self.checkmarkImageView.widthAnchor.constraint(equalToConstant: 18),
			self.checkmarkImageView.heightAnchor.constraint(equalToConstant: 18)
		])
	}

	/// Returns the localized display title for the given reason.
	///
	/// - Parameter reason: The reason whose title to return.
	///
	/// - Returns: The localized title.
	private static func displayTitle(for reason: ParentalGuideReportReason) -> String {
		switch reason {
		case .inaccurate:
			return L10n.reportReasonInaccurate
		case .spoiler:
			return L10n.reportReasonSpoiler
		case .spam:
			return L10n.reportReasonSpam
		case .inappropriate:
			return L10n.reportReasonInappropriate
		case .other:
			return L10n.reportReasonOther
		}
	}
}
