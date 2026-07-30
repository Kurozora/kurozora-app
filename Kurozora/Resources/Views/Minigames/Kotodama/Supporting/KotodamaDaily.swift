//
//  KotodamaDaily.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

struct KotodamaDaily: Hashable {
	// MARK: - Properties
	/// Today's puzzle.
	let puzzle: KotodamaDailyPuzzle?

	/// The player's game for today's puzzle.
	let game: KotodamaGame?

	/// The player's record.
	let stats: KotodamaUserStats?

	/// The fastest solves of today's puzzle.
	let topEntries: [KotodamaLeaderboardEntry]
}
