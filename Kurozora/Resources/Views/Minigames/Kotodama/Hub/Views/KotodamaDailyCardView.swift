//
//  KotodamaDailyCardView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaDailyCardView: UIView {
	// MARK: - Views
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let streakLabel = UILabel()

	/// The button that opens today's puzzle.
	let actionButton = KTintedButton()

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
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.layer.cornerCurve = .continuous
		self.layer.cornerRadius = 16

		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
		self.titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		self.addSubview(self.titleLabel)

		self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.subtitleLabel.adjustsFontForContentSizeCategory = true
		self.subtitleLabel.numberOfLines = 2
		self.subtitleLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		self.addSubview(self.subtitleLabel)

		self.streakLabel.translatesAutoresizingMaskIntoConstraints = false
		self.streakLabel.font = .preferredFont(forTextStyle: .footnote)
		self.streakLabel.adjustsFontForContentSizeCategory = true
		self.streakLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		self.addSubview(self.streakLabel)

		self.actionButton.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.actionButton)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
			self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
			self.streakLabel.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 10),
			self.streakLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			self.streakLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
			self.actionButton.topAnchor.constraint(equalTo: self.streakLabel.bottomAnchor, constant: 16),
			self.actionButton.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			self.actionButton.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
			self.actionButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -18),
			self.actionButton.heightAnchor.constraint(equalToConstant: 48)
		])
	}

	/// Configures the card with today's puzzle and the player's record.
	///
	/// - Parameters:
	///    - puzzle: Today's puzzle, if one is scheduled.
	///    - game: The player's game for today's puzzle.
	///    - stats: The player's record.
	///
	/// - Returns: The date the next daily puzzle unlocks, when the countdown should be shown in its place.
	@discardableResult
	func configure(puzzle: KotodamaDailyPuzzle?, game: KotodamaGame?, stats: KotodamaUserStats?) -> Date? {
		guard let puzzle = puzzle, let game = game else {
			self.titleLabel.text = L10n.kotodamaNoPuzzleToday
			self.subtitleLabel.text = L10n.kotodamaNoPuzzleTodayDescription
			self.streakLabel.text = nil
			self.actionButton.isHidden = true
			return nil
		}

		self.titleLabel.text = String(format: L10n.kotodamaDailyPuzzleNumber, puzzle.attributes.puzzleNumber)
		self.actionButton.isHidden = false

		if let streak = stats?.attributes.currentStreak, streak > 0 {
			self.streakLabel.text = String(format: L10n.kotodamaStreakValue, streak)
		} else {
			self.streakLabel.text = nil
		}

		let isFinished = game.attributes.status?.isFinished ?? false
		let hasStarted = game.attributes.guessCount > 0

		switch (isFinished, hasStarted) {
		case (true, _):
			self.actionButton.setTitle(L10n.kotodamaViewResult, for: .normal)
		case (false, true):
			self.actionButton.setTitle(L10n.continue, for: .normal)
		case (false, false):
			self.actionButton.setTitle(L10n.kotodamaPlay, for: .normal)
		}

		// Server midnight isn't the player's midnight, so a won or lost daily counts down
		// to the next one instead of repeating the tagline.
		let isWonOrLost = game.attributes.status == .won || game.attributes.status == .lost

		guard isWonOrLost, let nextPuzzleAt = puzzle.attributes.nextPuzzleAt, nextPuzzleAt > Date() else {
			self.subtitleLabel.text = L10n.kotodamaTagline
			return nil
		}

		self.showCountdown(until: nextPuzzleAt)
		return nextPuzzleAt
	}

	/// Shows the time remaining until the given date in place of the tagline.
	///
	/// - Parameter date: The date the next daily puzzle unlocks.
	func showCountdown(until date: Date) {
		let remaining = max(0, date.timeIntervalSinceNow)
		self.subtitleLabel.text = String(format: L10n.kotodamaNextIn, Self.formatCountdown(remaining))
	}

	/// Formats a duration as `HH:MM:SS`, padded with zeros.
	///
	/// - Parameter remaining: The duration to format, in seconds.
	///
	/// - Returns: The formatted duration.
	private static func formatCountdown(_ remaining: TimeInterval) -> String {
		let totalSeconds = Int(remaining.rounded(.up))
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
	}
}
