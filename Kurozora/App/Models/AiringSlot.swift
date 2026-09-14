//
//  AiringSlot.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A show's upcoming broadcast.
struct AiringSlot {
	// MARK: - Properties
	/// The identifier of the show.
	let showID: String

	/// The name of the show.
	let showTitle: String

	/// The identifier of the episode the broadcast carries.
	let episodeID: String

	/// The number of the episode within its season.
	let episodeNumber: Int

	/// The number of the episode within its series.
	let episodeNumberTotal: Int

	/// The URLs of the art the reminder shows, most specific first.
	let artURLStrings: [String]

	/// The moment the broadcast starts.
	let airingDate: Date

	/// The identifier the scheduled reminder carries.
	var identifier: String {
		return "\(AiringNotificationScheduler.identifierPrefix)episode-\(self.episodeID)"
	}

	/// The message the reminder carries.
	var body: String {
		guard self.episodeNumber != self.episodeNumberTotal else {
			return L10n.episodeNumberAiringNow(self.episodeNumberTotal)
		}

		return L10n.episodeNumberTotalAiringNow(self.episodeNumber, self.episodeNumberTotal)
	}

	/// The payload the reminder routes on.
	var userInfo: [String: Any] {
		return [
			"SHOW_ID": self.showID,
			"EPISODE_ID": self.episodeID,
			"path": "\(Scheme.episode.rawValue)/\(self.episodeID)"
		]
	}
}
