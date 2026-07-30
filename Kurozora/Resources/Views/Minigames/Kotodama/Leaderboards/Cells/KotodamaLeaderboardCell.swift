//
//  KotodamaLeaderboardCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaLeaderboardCell: KTableViewCell {
	// MARK: - Views
	/// The label displaying the entry's position on the leaderboard.
	private let rankLabel = KLabel()

	/// The image view displaying the player's profile picture.
	private let profileImageView = ProfileImageView(frame: .zero)

	/// The view outlining the profile image.
	private let borderView = BorderView()

	/// The label displaying the player's username.
	private let primaryLabel = KLabel()

	/// The label displaying the entry's detail string.
	private let secondaryLabel = KSecondaryLabel()

	// MARK: - Properties
	/// The reuse identifier of the cell.
	static let reuseIdentifier = "KotodamaLeaderboardCell"

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.configureSubviews()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	// MARK: - Functions
	/// Lays out the rank, profile image and player labels.
	private func configureSubviews() {
		self.rankLabel.translatesAutoresizingMaskIntoConstraints = false
		self.rankLabel.font = .preferredFont(forTextStyle: .headline)
		self.rankLabel.adjustsFontForContentSizeCategory = true
		self.rankLabel.textAlignment = .center
		self.rankLabel.setContentHuggingPriority(.required, for: .horizontal)
		self.rankLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.contentView.addSubview(self.rankLabel)

		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.profileImageView)

		self.borderView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.borderView)

		self.primaryLabel.translatesAutoresizingMaskIntoConstraints = false
		self.primaryLabel.font = .preferredFont(forTextStyle: .body)
		self.primaryLabel.adjustsFontForContentSizeCategory = true
		self.primaryLabel.numberOfLines = 2
		self.contentView.addSubview(self.primaryLabel)

		self.secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
		self.secondaryLabel.font = .preferredFont(forTextStyle: .caption1)
		self.secondaryLabel.adjustsFontForContentSizeCategory = true
		self.secondaryLabel.numberOfLines = 2
		self.contentView.addSubview(self.secondaryLabel)

		NSLayoutConstraint.activate([
			self.rankLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.rankLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),

			self.profileImageView.leadingAnchor.constraint(equalTo: self.rankLabel.trailingAnchor, constant: 12),
			self.profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
			self.profileImageView.widthAnchor.constraint(equalToConstant: 40),
			self.profileImageView.heightAnchor.constraint(equalToConstant: 40),

			self.borderView.leadingAnchor.constraint(equalTo: self.profileImageView.leadingAnchor),
			self.borderView.trailingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor),
			self.borderView.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
			self.borderView.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),

			self.primaryLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 12),
			self.primaryLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.primaryLabel.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),

			self.secondaryLabel.leadingAnchor.constraint(equalTo: self.primaryLabel.leadingAnchor),
			self.secondaryLabel.trailingAnchor.constraint(equalTo: self.primaryLabel.trailingAnchor),
			self.secondaryLabel.topAnchor.constraint(equalTo: self.primaryLabel.bottomAnchor, constant: 2),

			self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: self.profileImageView.bottomAnchor, constant: 10),
			self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: self.secondaryLabel.bottomAnchor, constant: 10)
		])
	}

	/// Configures the cell with a daily leaderboard entry.
	///
	/// - Parameter entry: The entry to show.
	func configure(using entry: KotodamaLeaderboardEntry) {
		let attributes = entry.attributes

		self.hideSkeleton()
		self.rankLabel.text = "#\(attributes.rank)"
		self.primaryLabel.text = entry.user?.attributes.username
		self.secondaryLabel.text = KotodamaSolveFormatter.detail(for: attributes)
		self.configureProfileImage(using: entry.user)
	}

	/// Configures the cell with a streak leaderboard entry.
	///
	/// - Parameter entry: The entry to show.
	func configure(using entry: KotodamaStreakEntry) {
		let attributes = entry.attributes

		self.hideSkeleton()
		self.rankLabel.text = "#\(attributes.rank)"
		self.primaryLabel.text = entry.user?.attributes.username
		self.secondaryLabel.text = String(
			format: L10n.kotodamaStreakDetail,
			attributes.maxStreak,
			attributes.currentStreak
		)
		self.configureProfileImage(using: entry.user)
	}

	/// Loads the player's profile image.
	///
	/// - Parameter user: The player behind the entry.
	private func configureProfileImage(using user: User?) {
		guard let user = user else {
			self.profileImageView.image = .Placeholders.userProfile
			return
		}

		user.attributes.profileImage(imageView: self.profileImageView)
	}
}
