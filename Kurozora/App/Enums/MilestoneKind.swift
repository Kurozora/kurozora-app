//
//  MilestoneKind.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation

/// The set of available milestone kinds.
enum MilestoneKind: Int, CaseIterable {
	// MARK: - Cases
	/// The milestone indicating a user's watched minutes.
	case minuetsWatched

	/// The milestone indicating a user's number of watched episodes.
	case episodesWatched

	/// The milestone indicating a user's read minutes.
	case minuetsRead

	/// The milestone indicating a user's number of read chapters.
	case chaptersRead

	/// The milestone indicating a user's played minutes.
	case minutesPlayed

	/// The milestone indicating a user's number of played games.
	case gamesPlayed

	/// The milestone indicating a user's top percentile.
	case topPercentile

	// MARK: - Properties
	/// The string value of a `MilestoneKind` type.
	var stringValue: String {
		switch self {
		case .minuetsWatched:
			return "Minutes Watched"
		case .episodesWatched:
			return "Episodes Watched"
		case .minuetsRead:
			return "Minutes Read"
		case .chaptersRead:
			return "Chapters Read"
		case .minutesPlayed:
			return "Minutes Played"
		case .gamesPlayed:
			return "Games Played"
		case .topPercentile:
			return "Top Percentile"
		}
	}

	/// The unit value of a `MilestoneKind` type.
	var unitValue: String {
		switch self {
		case .minuetsWatched, .minuetsRead, .minutesPlayed:
			return "Minutes"
		case .episodesWatched:
			return "Episodes"
		case .chaptersRead:
			return "Chapters"
		case .gamesPlayed:
			return "Games"
		case .topPercentile:
			return "Percentile"
		}
	}
}
