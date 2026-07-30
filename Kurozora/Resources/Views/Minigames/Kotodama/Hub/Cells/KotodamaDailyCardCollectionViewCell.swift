//
//  KotodamaDailyCardCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KotodamaDailyCardCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate that the card's action button was pressed.
	func kotodamaDailyCardCellDidPressAction(_ cell: KotodamaDailyCardCollectionViewCell)
}

class KotodamaDailyCardCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let cardView = KotodamaDailyCardView()

	// MARK: - Properties
	/// The object that acts as the delegate of the cell.
	weak var delegate: KotodamaDailyCardCollectionViewCellDelegate?

	/// The timer ticking the countdown to the next daily puzzle.
	private var countdownTimer: Timer?

	/// The date the next daily puzzle unlocks, while the countdown is running.
	private var nextPuzzleAt: Date?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	deinit {
		self.countdownTimer?.invalidate()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.stopCountdown()
	}

	// MARK: - Functions
	/// The shared init of the cell.
	private func sharedInit() {
		self.contentView.addSubview(self.cardView)
		self.cardView.actionButton.addTarget(self, action: #selector(self.actionButtonPressed), for: .touchUpInside)

		NSLayoutConstraint.activate([
			self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
		])
	}

	/// Configures the cell with today's puzzle and the player's record.
	///
	/// - Parameter daily: Today's puzzle, the player's game for it, and their record.
	func configure(using daily: KotodamaDaily) {
		self.stopCountdown()

		guard let nextPuzzleAt = self.cardView.configure(puzzle: daily.puzzle, game: daily.game, stats: daily.stats) else {
			return
		}

		self.startCountdown(until: nextPuzzleAt)
	}

	/// Starts ticking the countdown to the given date, once per second.
	///
	/// - Parameter date: The date the next daily puzzle unlocks.
	private func startCountdown(until date: Date) {
		self.nextPuzzleAt = date

		let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
			self?.tickCountdown()
		}
		RunLoop.main.add(timer, forMode: .common)
		self.countdownTimer = timer
	}

	/// Advances the countdown by one tick, computing the remainder from the current date to avoid drift.
	private func tickCountdown() {
		guard let nextPuzzleAt = self.nextPuzzleAt else { return }

		guard nextPuzzleAt > Date() else {
			self.stopCountdown()
			NotificationCenter.default.post(name: .KKotodamaNextDailyDidUnlock, object: nil)
			return
		}

		self.cardView.showCountdown(until: nextPuzzleAt)
	}

	/// Stops the countdown timer, leaving the card's last drawn text in place.
	private func stopCountdown() {
		self.countdownTimer?.invalidate()
		self.countdownTimer = nil
		self.nextPuzzleAt = nil
	}

	/// Notifies the delegate that the action button was pressed.
	@objc private func actionButtonPressed() {
		self.delegate?.kotodamaDailyCardCellDidPressAction(self)
	}
}
