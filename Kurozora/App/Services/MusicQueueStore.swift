//
//  MusicQueueStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import os.log

private let musicQueueStoreLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "MusicQueueStore")

/// Stores the playback queue between sessions.
struct MusicQueueStore {
	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Saves the given queue.
	///
	/// - Parameter snapshot: The queue to save.
	static func save(_ snapshot: Snapshot) {
		do {
			let snapshotData = try JSONEncoder().encode(snapshot)
			let fileURL = try Self.fileURL(creatingDirectory: true)
			try snapshotData.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
		} catch {
			musicQueueStoreLogger.error("Save failed: \(error.localizedDescription)")
		}
	}

	/// Returns the queue the previous session left behind.
	///
	/// - Returns: The saved queue.
	static func load() -> Snapshot? {
		do {
			let fileURL = try Self.fileURL(creatingDirectory: false)
			let snapshotData = try Data(contentsOf: fileURL)
			return try JSONDecoder().decode(Snapshot.self, from: snapshotData)
		} catch {
			return nil
		}
	}

	/// Removes the saved queue.
	static func clear() {
		guard let fileURL = try? Self.fileURL(creatingDirectory: false) else { return }
		try? FileManager.default.removeItem(at: fileURL)
	}

	// MARK: - Helpers
	/// Returns the on-disk location of the saved queue.
	///
	/// - Parameter creatingDirectory: Whether the enclosing directory is created when it is missing.
	///
	/// - Returns: The file the queue is written to.
	private static func fileURL(creatingDirectory: Bool) throws -> URL {
		let applicationSupportURL = try FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: creatingDirectory
		)
		return applicationSupportURL.appendingPathComponent("MusicQueue.json", isDirectory: false)
	}
}

// MARK: - Snapshot
extension MusicQueueStore {
	/// A playback queue as it stood at the end of a session.
	struct Snapshot: Codable {
		/// The Apple Music songs forming the queue.
		let songs: [MKSong]

		/// The Kurozora models aligned by index with ``songs``.
		let kkSongs: [KKSong]

		/// The index of the song the queue rests on.
		let index: Int

		/// How far playback had reached into that song, in seconds.
		let positionSeconds: TimeInterval

		/// Whether shuffle was on.
		let shuffleEnabled: Bool

		/// The repeat mode the queue was playing under.
		let repeatMode: PlaybackRepeatMode
	}
}
