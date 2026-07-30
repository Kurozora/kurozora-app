//
//  KotodamaStreakView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaStreakView: UIView {
	// MARK: - Views
	private let summaryView = KotodamaStatGridView()

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

		self.summaryView.translatesAutoresizingMaskIntoConstraints = false
		self.summaryView.showsTiles = true
		self.addSubview(self.summaryView)

		NSLayoutConstraint.activate([
			self.summaryView.topAnchor.constraint(equalTo: self.topAnchor),
			self.summaryView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.summaryView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.summaryView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	/// Configures the tiles with the player's record.
	///
	/// - Parameter stats: The player's record.
	func configure(using stats: KotodamaUserStats?) {
		let attributes = stats?.attributes
		let winRate = NumberFormatter.localizedString(
			from: NSNumber(value: attributes?.winRate ?? 0),
			number: .percent
		)

		self.summaryView.configure(using: [
			KotodamaStat(title: L10n.kotodamaGamesPlayed, value: "\(attributes?.gamesPlayed ?? 0)"),
			KotodamaStat(title: L10n.kotodamaWinRate, value: winRate),
			KotodamaStat(title: L10n.kotodamaCurrentStreak, value: "\(attributes?.currentStreak ?? 0)"),
			KotodamaStat(title: L10n.kotodamaBestStreak, value: "\(attributes?.maxStreak ?? 0)")
		])
	}
}
