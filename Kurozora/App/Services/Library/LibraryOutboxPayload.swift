//
//  LibraryOutboxPayload.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The mutation-specific value carried by a pending `LocalOutboxOperation`.
struct LibraryOutboxPayload: Codable, Sendable {
	/// Raw value of the target `LibraryStatus`, for `setStatus`.
	var statusRaw: Int?

	/// The target boolean, for `setFavorite`, `setReminder`, and `setHidden`.
	var flag: Bool?

	/// The target rewatch count, for `setRewatchCount`.
	var rewatchCount: Int?

	/// The submitted rating, for `rate`.
	var score: Double?

	/// The submitted review text, for `rate`.
	var reviewDescription: String?

	/// Raw value of the target `WatchStatus`, for `setEpisodeWatchStatus` and `setSeasonWatchStatus`.
	var watchStatusRaw: Int?
}
