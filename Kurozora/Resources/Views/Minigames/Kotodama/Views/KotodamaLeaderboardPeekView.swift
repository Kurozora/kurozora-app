//
//  KotodamaLeaderboardPeekView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KotodamaLeaderboardPeekViewDelegate: AnyObject {
	/// Tells the delegate that the see all button was pressed.
	func kotodamaLeaderboardPeekViewDidPressSeeAll(_ peekView: KotodamaLeaderboardPeekView)
}

class KotodamaLeaderboardPeekView: UIView {
	// MARK: - Views
	private let contentStackView = UIStackView()
	private let headerStackView = UIStackView()
	private let titleLabel = UILabel()
	private let seeAllButton = KButton()
	private let entriesStackView = UIStackView()
	private let emptyLabel = UILabel()

	// MARK: - Properties
	/// The object that acts as the delegate of the peek view.
	weak var delegate: KotodamaLeaderboardPeekViewDelegate?

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

		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .vertical
		self.contentStackView.alignment = .fill
		self.contentStackView.spacing = 12
		self.addSubview(self.contentStackView)

		self.titleLabel.text = L10n.kotodamaTodaysFastest
		self.titleLabel.font = .preferredFont(forTextStyle: .headline)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue

		self.seeAllButton.setTitle(L10n.seeAll, for: .normal)
		self.seeAllButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
		self.seeAllButton.addTarget(self, action: #selector(self.seeAllButtonPressed), for: .touchUpInside)
		self.seeAllButton.setContentHuggingPriority(.required, for: .horizontal)

		self.headerStackView.axis = .horizontal
		self.headerStackView.alignment = .center
		self.headerStackView.spacing = 8
		self.headerStackView.addArrangedSubview(self.titleLabel)
		self.headerStackView.addArrangedSubview(self.seeAllButton)

		self.entriesStackView.axis = .vertical
		self.entriesStackView.alignment = .fill
		self.entriesStackView.spacing = 8

		self.emptyLabel.text = L10n.kotodamaNobodySolvedToday
		self.emptyLabel.numberOfLines = 0
		self.emptyLabel.font = .preferredFont(forTextStyle: .footnote)
		self.emptyLabel.adjustsFontForContentSizeCategory = true
		self.emptyLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		self.contentStackView.addArrangedSubview(self.headerStackView)
		self.contentStackView.addArrangedSubview(self.entriesStackView)
		self.contentStackView.addArrangedSubview(self.emptyLabel)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	/// Configures the view with the fastest solves.
	///
	/// - Parameter entries: The fastest solves of today's puzzle.
	func configure(using entries: [KotodamaLeaderboardEntry]) {
		self.entriesStackView.arrangedSubviews.forEach {
			self.entriesStackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}

		self.emptyLabel.isHidden = !entries.isEmpty
		self.entriesStackView.isHidden = entries.isEmpty

		for entry in entries {
			self.entriesStackView.addArrangedSubview(self.makeEntryView(for: entry))
		}
	}

	/// Returns a row showing one solve.
	///
	/// - Parameter entry: The solve to show.
	///
	/// - Returns: The row to add to the list.
	private func makeEntryView(for entry: KotodamaLeaderboardEntry) -> UIView {
		let containerView = UIView()
		containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		containerView.layer.cornerCurve = .continuous
		containerView.layer.cornerRadius = 8
		containerView.layer.borderWidth = 1
		containerView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker

		let rankLabel = UILabel()
		rankLabel.translatesAutoresizingMaskIntoConstraints = false
		rankLabel.text = "\(entry.attributes.rank)"
		rankLabel.font = .preferredFont(forTextStyle: .subheadline)
		rankLabel.adjustsFontForContentSizeCategory = true
		rankLabel.textAlignment = .center
		rankLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		rankLabel.setContentHuggingPriority(.required, for: .horizontal)
		rankLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		containerView.addSubview(rankLabel)

		let profileImageView = ProfileImageView(frame: .zero)
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(profileImageView)

		let borderView = BorderView()
		borderView.translatesAutoresizingMaskIntoConstraints = false
		borderView.cornerRadius = 16
		borderView.isUserInteractionEnabled = false
		containerView.addSubview(borderView)

		self.configureProfileImage(profileImageView, using: entry.user)

		let usernameLabel = UILabel()
		usernameLabel.translatesAutoresizingMaskIntoConstraints = false
		usernameLabel.text = entry.user?.attributes.username
		usernameLabel.font = .preferredFont(forTextStyle: .subheadline)
		usernameLabel.adjustsFontForContentSizeCategory = true
		usernameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		containerView.addSubview(usernameLabel)

		let detailLabel = UILabel()
		detailLabel.translatesAutoresizingMaskIntoConstraints = false
		detailLabel.text = KotodamaSolveFormatter.detail(for: entry.attributes)
		detailLabel.font = .preferredFont(forTextStyle: .footnote)
		detailLabel.adjustsFontForContentSizeCategory = true
		detailLabel.textAlignment = .right
		detailLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		detailLabel.setContentHuggingPriority(.required, for: .horizontal)
		containerView.addSubview(detailLabel)

		NSLayoutConstraint.activate([
			rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),

			profileImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 12),
			profileImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
			profileImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
			profileImageView.widthAnchor.constraint(equalToConstant: 32),
			profileImageView.heightAnchor.constraint(equalToConstant: 32),

			borderView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			borderView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
			borderView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
			borderView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),

			usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
			usernameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

			detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor, constant: 8),
			detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			detailLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
		])

		return containerView
	}

	/// Loads a solver's profile image into the given image view.
	///
	/// - Parameters:
	///    - profileImageView: The image view to load into.
	///    - user: The player behind the entry.
	private func configureProfileImage(_ profileImageView: ProfileImageView, using user: User?) {
		guard let user = user else {
			profileImageView.image = .Placeholders.userProfile
			return
		}

		user.attributes.profileImage(imageView: profileImageView)
	}

	/// Notifies the delegate that the see all button was pressed.
	@objc private func seeAllButtonPressed() {
		self.delegate?.kotodamaLeaderboardPeekViewDidPressSeeAll(self)
	}
}
