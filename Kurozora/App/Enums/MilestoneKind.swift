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
			return L10n.milestoneMinutesWatched
		case .episodesWatched:
			return L10n.milestoneEpisodesWatched
		case .minuetsRead:
			return L10n.milestoneMinutesRead
		case .chaptersRead:
			return L10n.milestoneChaptersRead
		case .minutesPlayed:
			return L10n.milestoneMinutesPlayed
		case .gamesPlayed:
			return L10n.milestoneGamesPlayed
		case .topPercentile:
			return L10n.milestoneTopPercentile
		}
	}

	/// The unit value of a `MilestoneKind` type.
	var unitValue: String {
		switch self {
		case .minuetsWatched, .minuetsRead, .minutesPlayed:
			return L10n.unitMinutes
		case .episodesWatched:
			return L10n.episodes
		case .chaptersRead:
			return L10n.columnChapters
		case .gamesPlayed:
			return L10n.games
		case .topPercentile:
			return L10n.unitPercentile
		}
	}
}
