//
//  KotodamaShareGrid.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Foundation

/// The shareable emoji grid of a finished game.
struct KotodamaShareGrid {
	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns the shareable text for a finished game.
	///
	/// - Parameter game: The finished game to describe.
	///
	/// - Returns: The text shared for the game.
	static func text(for game: KotodamaGame) -> String {
		let rows = game.attributes.guesses
			.sorted { $0.position < $1.position }
			.map { guess in
				guess.tiles.map(\.emojiValue).joined()
			}

		return ([self.header(for: game), ""] + rows).joined(separator: "\n")
	}

	/// Returns the header naming the puzzle and its outcome.
	///
	/// - Parameter game: The finished game to describe.
	///
	/// - Returns: The header of the shareable text.
	private static func header(for game: KotodamaGame) -> String {
		let attributes = game.attributes
		let score = attributes.status == .won
			? "\(attributes.guessCount)/\(attributes.maxGuesses)"
			: "X/\(attributes.maxGuesses)"

		guard attributes.mode == .daily, let puzzleNumber = game.dailyPuzzle?.attributes.puzzleNumber else {
			return String(format: L10n.kotodamaShareGridHeader, score)
		}

		return String(format: L10n.kotodamaShareGridDailyHeader, puzzleNumber, score)
	}
}
