//
//  MarkEpisodeWatchedIntent.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 11/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AppIntents
import KurozoraKit
import WidgetKit

/// Prevents duplicate mark-as-watched API calls using file-based atomic locking.
///
/// Uses `O_CREAT | O_EXCL` to atomically create a lock file  this is a single
/// syscall that either succeeds or fails, with no race window. Works reliably
/// across concurrent intent executions and process boundaries.
enum PendingWatchedStore {
	/// The directory where lock files are stored. Each lock file is named after the episode ID it corresponds to.
	private static var lockDirectory: URL {
		FileManager.default.temporaryDirectory.appendingPathComponent("watched-locks", isDirectory: true)
	}

	/// Returns the URL for the lock file corresponding to the given episode ID.
	///
	/// - Parameter episodeID: The ID of the episode for which to get the lock URL.
	///
	/// - Returns: The URL of the lock file for the episode.
	private static func lockURL(for episodeID: String) -> URL {
		try? FileManager.default.createDirectory(at: self.lockDirectory, withIntermediateDirectories: true)
		return self.lockDirectory.appendingPathComponent(episodeID)
	}

	/// Atomically acquires a lock for the episode. Returns `true` if acquired, `false` if already locked by another execution.
	///
	/// - Parameter episodeID: The ID of the episode to lock.
	///
	/// - Returns: `true` if the lock was successfully acquired, `false` if the episode is already locked.
	static func tryLock(_ episodeID: String) -> Bool {
		let url = self.lockURL(for: episodeID)

		// Clean up stale locks older than 60 seconds. For example when the intent crashes.
		if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
		   let modDate = attrs[.modificationDate] as? Date,
		   Date().timeIntervalSince(modDate) > 60 {
			try? FileManager.default.removeItem(at: url)
		}

		let fd = open(url.path, O_CREAT | O_EXCL | O_WRONLY, 0o644)
		guard fd != -1 else { return false }
		close(fd)
		return true
	}

	/// Releases the lock for the episode.
	///
	/// - Parameter episodeID: The ID of the episode to unlock.
	static func unlock(_ episodeID: String) {
		try? FileManager.default.removeItem(at: self.lockURL(for: episodeID))
	}

	/// Returns whether the episode is currently locked (API in-flight).
	///
	/// - Parameter episodeID: The ID of the episode to check.
	///
	/// - Returns: `true` if the episode is locked, `false` otherwise.
	static func isPending(_ episodeID: String) -> Bool {
		return FileManager.default.fileExists(atPath: self.lockURL(for: episodeID).path)
	}
}

// MARK: - Mark Episode Watched Intent
/// An `AppIntent` that marks an episode as watched and refreshes the Up Next widget.
@available(iOS 17.0, macOS 14.0, *)
struct MarkEpisodeWatchedIntent: AppIntent {
	// MARK: - Properties
	static let title: LocalizedStringResource = "Mark Episode as Watched"
	static let description = IntentDescription("Marks an episode as watched and refreshes the Up Next widget.")

	@Parameter(title: "Episode ID")
	var episodeID: String

	// MARK: - Initialization
	init() {}

	init(episodeID: String) {
		self.episodeID = episodeID
	}

	// MARK: - AppIntent
	func perform() async throws -> some IntentResult {
		// Prevents concurrent executions for the same episode
		guard PendingWatchedStore.tryLock(self.episodeID) else {
			return .result()
		}

		// Restore authentication
		let slug = UserSettings.selectedAccount
		if !slug.isEmpty, let account = AccountManager.shared.account(forSlug: slug) {
			KService.authenticationKey = account.authenticationToken
		}

		// Request a reload so the widget can show the pending state while the API runs.
		await WidgetCenter.shared.reloadTimelines(ofKind: UpNextWidget.kind)

		do {
			let identity = EpisodeIdentity(id: KurozoraItemID(self.episodeID))
			_ = try await KService.updateEpisodeWatchStatus(identity)
		} catch {
			// Unlock on failure so the user can retry
			PendingWatchedStore.unlock(self.episodeID)
			await WidgetCenter.shared.reloadTimelines(ofKind: UpNextWidget.kind)
			throw error
		}

		// We don't unlock on success. The lock stays until the 60 second stale expiry.
		// This prevents a second tap from toggling the watch status back while the
		// widget is still refreshing with the old UI.
		await WidgetCenter.shared.reloadTimelines(ofKind: UpNextWidget.kind)

		return .result()
	}
}
