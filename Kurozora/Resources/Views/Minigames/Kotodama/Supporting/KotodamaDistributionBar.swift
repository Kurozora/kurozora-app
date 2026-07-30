//
//  KotodamaDistributionBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

struct KotodamaDistributionBar: Hashable {
	// MARK: - Properties
	/// The shortest fill a bucket with wins is drawn at.
	static let minimumPercent = 4

	/// The number of guesses the bucket represents.
	let guessCount: Int

	/// The number of wins in the bucket.
	let wins: Int

	/// The share of the bar to fill, between `0` and `100`.
	let percent: Int

	// MARK: - Initializers
	/// Creates a bucket measured against the busiest bucket.
	///
	/// - Parameters:
	///    - guessCount: The number of guesses the bucket represents.
	///    - wins: The number of wins in the bucket.
	///    - busiest: The number of wins in the busiest bucket.
	init(guessCount: Int, wins: Int, busiest: Int) {
		self.guessCount = guessCount
		self.wins = wins

		guard wins > 0, busiest > 0 else {
			self.percent = 0
			return
		}

		self.percent = max(Self.minimumPercent, Int((Double(wins) / Double(busiest) * 100).rounded()))
	}
}
