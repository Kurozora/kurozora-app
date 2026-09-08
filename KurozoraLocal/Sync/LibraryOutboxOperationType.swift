//
//  LibraryOutboxOperationType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The kind of mutation recorded by a pending `LocalOutboxOperation`.
enum LibraryOutboxOperationType: Int16, Sendable, CaseIterable {
	case setStatus = 0
	case remove = 1
	case setFavorite = 2
	case setReminder = 3
	case setHidden = 4
	case setRewatchCount = 5
	case rate = 6
	case deleteRating = 7
	case setEpisodeWatchStatus = 8
	case setSeasonWatchStatus = 9

	/// Whether the operation changes a `LocalLibraryEntry` row rather than an episode or season watch status.
	nonisolated var mutatesLibraryEntry: Bool {
		switch self {
		case .setStatus, .remove, .setFavorite, .setReminder, .setHidden, .setRewatchCount, .rate, .deleteRating:
			return true
		case .setEpisodeWatchStatus, .setSeasonWatchStatus:
			return false
		}
	}
}
