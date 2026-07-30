//
//  KotodamaSolveFormatter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Foundation

enum KotodamaSolveFormatter {
	// MARK: - Functions
	/// Returns the guesses spent and the time taken for a solve.
	///
	/// - Parameter attributes: The leaderboard entry to describe.
	///
	/// - Returns: The detail shown alongside the player's name.
	static func detail(for attributes: KotodamaLeaderboardEntry.Attributes) -> String {
		let guesses = String(format: L10n.kotodamaGuessesSpent, attributes.guessCount, Kotodama.maxGuesses)

		guard let durationMs = attributes.durationMs else {
			return guesses
		}

		let seconds = NumberFormatter.localizedString(
			from: NSNumber(value: Double(durationMs) / 1000),
			number: .decimal
		)

		return String(format: L10n.kotodamaGuessesAndSeconds, guesses, seconds)
	}
}
