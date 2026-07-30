//
//  KotodamaMode.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

enum KotodamaMode: Int, CaseIterable {
	// MARK: - Cases
	/// A practice puzzle drawn at random.
	case unlimited

	/// The archive of past puzzles.
	case archive

	/// The leaderboards.
	case leaderboards

	/// The signed-in player's record.
	case stats

	// MARK: - Properties
	/// The name of the symbol shown at the leading edge.
	var symbolName: String {
		switch self {
		case .unlimited:
			return "infinity"
		case .archive:
			return "calendar"
		case .leaderboards:
			return "trophy"
		case .stats:
			return "chart.bar"
		}
	}

	/// The title of the row.
	var stringValue: String {
		switch self {
		case .unlimited:
			return L10n.kotodamaUnlimited
		case .archive:
			return L10n.kotodamaArchive
		case .leaderboards:
			return L10n.kotodamaLeaderboards
		case .stats:
			return L10n.kotodamaStats
		}
	}

	/// The description of the row.
	var detailStringValue: String {
		switch self {
		case .unlimited:
			return L10n.kotodamaUnlimitedDescription
		case .archive:
			return L10n.kotodamaArchiveDescription
		case .leaderboards:
			return L10n.kotodamaLeaderboardsDescription
		case .stats:
			return L10n.kotodamaStatsDescription
		}
	}
}
