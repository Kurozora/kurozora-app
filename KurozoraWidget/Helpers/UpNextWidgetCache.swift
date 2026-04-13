//
//  UpNextWidgetCache.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// A serializable snapshot of an episode displayed by the Up Next widget.
///
/// Persisted to the App Group suite so the widget can re-hydrate the last
/// successfully rendered timeline when the server is unreachable, without
/// re-issuing any network calls. Image bytes are not stored — the paired
/// image URL is looked up in ``ImageFetcher``'s disk cache at render time.
struct UpNextEpisodeSnapshot: Codable {
	let id: String
	let title: String
	let showTitle: String
	let seasonNumber: Int
	let episodeNumber: Int
	let episodeNumberTotal: Int
	let imageURL: URL?
	let backgroundColor: String?
	let deeplinkURLString: String
	let isFiller: Bool
}

/// App Group–backed cache for the Up Next widget.
///
/// Remembers the last successfully fetched timeline plus a count of consecutive
/// failures, so repeated failures back off exponentially instead of hammering
/// an unreachable server. Works across widget reloads because it lives in the
/// shared App Group `UserDefaults` suite used by the main app.
enum UpNextWidgetCache {
	private static let suiteName = "group.settings.app.kurozora.tracker"

	private enum Key {
		static let lastGoodSnapshot = "upNext.lastGoodSnapshot"
		static let lastSuccessAt = "upNext.lastSuccessAt"
		static let upNextConsecutiveFailures = "upNext.consecutiveFailures"
		static let dateConsecutiveFailures = "date.consecutiveFailures"
	}

	private static var defaults: UserDefaults {
		UserDefaults(suiteName: self.suiteName) ?? .standard
	}

	// MARK: - Snapshot Persistence
	/// Persists the successfully fetched timeline and resets the Up Next failure counter.
	///
	/// - Parameter snapshots: The snapshots that were just rendered successfully.
	static func recordUpNextSuccess(_ snapshots: [UpNextEpisodeSnapshot]) {
		if let data = try? JSONEncoder().encode(snapshots) {
			self.defaults.set(data, forKey: Key.lastGoodSnapshot)
			self.defaults.set(Date(), forKey: Key.lastSuccessAt)
		}
		self.defaults.set(0, forKey: Key.upNextConsecutiveFailures)
	}

	/// Increments and returns the Up Next consecutive failure counter.
	@discardableResult
	static func recordUpNextFailure() -> Int {
		let count = self.defaults.integer(forKey: Key.upNextConsecutiveFailures) + 1
		self.defaults.set(count, forKey: Key.upNextConsecutiveFailures)
		return count
	}

	/// Loads the last successfully persisted snapshot, if any.
	static func loadLastGoodSnapshot() -> [UpNextEpisodeSnapshot]? {
		guard let data = self.defaults.data(forKey: Key.lastGoodSnapshot) else { return nil }
		return try? JSONDecoder().decode([UpNextEpisodeSnapshot].self, from: data)
	}

	// MARK: - Date Widget Counters
	/// Resets the Date widget consecutive failure counter after a successful fetch.
	static func recordDateSuccess() {
		self.defaults.set(0, forKey: Key.dateConsecutiveFailures)
	}

	/// Increments and returns the Date widget consecutive failure counter.
	@discardableResult
	static func recordDateFailure() -> Int {
		let count = self.defaults.integer(forKey: Key.dateConsecutiveFailures) + 1
		self.defaults.set(count, forKey: Key.dateConsecutiveFailures)
		return count
	}

	// MARK: - Backoff
	/// Computes the next-reload interval for the given consecutive failure count.
	///
	/// Schedule (capped at 4 hours):
	/// - 1 failure   -> 10 minutes
	/// - 2 failures  -> 30 minutes
	/// - 3 failures  -> 1 hour
	/// - 4 failures  -> 2 hours
	/// - 5+ failures -> 4 hours
	static func backoffInterval(forFailures failures: Int) -> TimeInterval {
		switch failures {
		case ..<1: return 60 * 60 // Defensive: treat 0 as a normal 1h refresh.
		case 1: return 10 * 60
		case 2: return 30 * 60
		case 3: return 60 * 60
		case 4: return 2 * 60 * 60
		default: return 4 * 60 * 60
		}
	}
}
