//
//  LibrarySyncProgress+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

extension LibrarySyncProgress {
	/// A sentence describing how recently the library synced.
	///
	/// - Parameter lastSyncDate: The date of the most recent sync.
	///
	/// - Returns: The sentence.
	static func lastSyncSentence(for lastSyncDate: Date?) -> String {
		guard let lastSyncDate else { return L10n.neverSynced }

		let elapsedMinutes = Int(Date().timeIntervalSince(lastSyncDate) / 60)

		if elapsedMinutes < 10 {
			return L10n.syncedJustNow
		} else if elapsedMinutes < 60 {
			return L10n.lastSyncedMinutesAgo(elapsedMinutes)
		} else if elapsedMinutes < 60 * 24 {
			return L10n.lastSyncedHoursAgo(elapsedMinutes / 60)
		}

		return L10n.lastSyncedOnDate(lastSyncDate.appFormatted(date: .abbreviated, time: .omitted))
	}
}
