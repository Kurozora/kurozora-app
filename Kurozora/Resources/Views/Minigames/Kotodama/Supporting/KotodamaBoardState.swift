//
//  KotodamaBoardState.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

struct KotodamaBoardState {
	// MARK: - Properties
	/// The rows of the board, from the first guess to the last.
	let rows: [[KotodamaTileState]]

	/// The strongest feedback received for every letter guessed so far.
	let keyboard: [Swift.Character: KotodamaTileFeedback]

	/// The index of the row accepting input.
	let activeRowIndex: Int?

	// MARK: - Initializers
	/// Creates the state for a game and the letters typed but not yet submitted.
	///
	/// - Parameters:
	///    - game: The game to lay out.
	///    - pendingGuess: The letters typed but not yet submitted.
	init(game: KotodamaGame, pendingGuess: String) {
		let length = max(1, game.word?.attributes.length ?? Kotodama.wordLength)
		let maxGuesses = max(1, game.attributes.maxGuesses)
		let isFinished = game.attributes.status?.isFinished ?? false
		let submitted = game.attributes.guesses.sorted { $0.position < $1.position }

		var rows: [[KotodamaTileState]] = []
		var keyboard: [Swift.Character: KotodamaTileFeedback] = [:]

		for guess in submitted.prefix(maxGuesses) {
			let letters = Array(guess.guess.uppercased())
			let feedback = guess.tiles
			var row: [KotodamaTileState] = []

			for index in 0..<length {
				guard index < letters.count, index < feedback.count else {
					row.append(.empty)
					continue
				}

				row.append(.revealed(letter: letters[index], feedback: feedback[index]))
				keyboard[letters[index]] = Self.strongest(keyboard[letters[index]], feedback[index])
			}

			rows.append(row)
		}

		let activeRowIndex = isFinished || rows.count >= maxGuesses ? nil : rows.count
		let pendingLetters = Array(pendingGuess.uppercased())

		while rows.count < maxGuesses {
			let isActiveRow = rows.count == activeRowIndex
			var row: [KotodamaTileState] = []

			for index in 0..<length {
				if isActiveRow, index < pendingLetters.count {
					row.append(.pending(letter: pendingLetters[index]))
				} else {
					row.append(.empty)
				}
			}

			rows.append(row)
		}

		self.rows = rows
		self.keyboard = keyboard
		self.activeRowIndex = activeRowIndex
	}

	// MARK: - Functions
	/// Returns the more informative of two feedback values.
	///
	/// - Parameters:
	///    - lhs: The feedback recorded so far, if any.
	///    - rhs: The feedback to merge in.
	///
	/// - Returns: The feedback that should be shown on the keyboard.
	private static func strongest(_ lhs: KotodamaTileFeedback?, _ rhs: KotodamaTileFeedback) -> KotodamaTileFeedback {
		guard let lhs = lhs else { return rhs }
		return Self.rank(lhs) >= Self.rank(rhs) ? lhs : rhs
	}

	/// Returns how informative a feedback value is.
	///
	/// - Parameter feedback: The feedback to rank.
	///
	/// - Returns: The rank of the feedback.
	private static func rank(_ feedback: KotodamaTileFeedback) -> Int {
		switch feedback {
		case .hit:
			return 2
		case .present:
			return 1
		case .miss:
			return 0
		}
	}
}
