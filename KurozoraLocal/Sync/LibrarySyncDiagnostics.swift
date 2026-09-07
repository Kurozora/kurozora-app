//
//  LibrarySyncDiagnostics.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import os.log

/// Emits a deterministic, diffable snapshot of the local library state for divergence debugging.
enum LibrarySyncDiagnostics {
	private static let logger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibraryDiag")

	/// The maximum number of snapshots retained in the on-disk diagnostics log.
	private static let maximumSnapshots = 50

	/// The Documents-relative path of the on-disk diagnostics log.
	private static let fileName = "library-diagnostics.json"

	// MARK: - Types
	private struct StateSnapshot: Codable {
		let reason: String
		let kinds: [String: KindState]
	}

	private struct KindState: Codable {
		let count: Int
		let ops: Int
		let cursor: String?
		let entries: [Row]
	}

	private struct Row: Codable {
		let trackable: String
		let status: Int
		let favorited: Int
		let reminded: Int
		let hidden: Int
		let rewatch: Int
		let score: Double?
		let updatedAt: Int?
		let origin: String

		private enum CodingKeys: String, CodingKey {
			case trackable = "t"
			case status = "s"
			case favorited = "f"
			case reminded = "r"
			case hidden = "h"
			case rewatch = "rw"
			case score = "sc"
			case updatedAt = "u"
			case origin
		}
	}

	// MARK: - Functions
	/// Records a per-kind fingerprint of the local library state for the given account.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - reason: A short label identifying what triggered the dump.
	static func logState(forUserSlug userSlug: String, reason: String) async {
		let context = PersistenceController.shared.container.newBackgroundContext()

		let snapshot = await context.perform { () -> StateSnapshot in
			var kinds: [String: KindState] = [:]

			for kind in LibraryKind.allCases {
				let entryRequest = LocalLibraryEntry.fetchRequest()
				entryRequest.predicate = NSPredicate(format: "userSlug == %@ AND kindRaw == %d", userSlug, Int64(kind.rawValue))
				entryRequest.sortDescriptors = [NSSortDescriptor(key: "trackableID", ascending: true)]
				let entries = (try? context.fetch(entryRequest)) ?? []

				let cursorRow = LocalSyncCursor.fetch(forUserSlug: userSlug, kind: kind, in: context)

				let opRequest = LocalOutboxOperation.fetchRequest()
				opRequest.predicate = NSPredicate(format: "userSlug == %@ AND kindRaw == %d", userSlug, Int64(kind.rawValue))
				let opCount = (try? context.count(for: opRequest)) ?? 0

				kinds[String(kind.rawValue)] = KindState(
					count: entries.count,
					ops: opCount,
					cursor: cursorRow.map { "\($0.cursorUpdatedAt ?? "nil")|\($0.cursorID ?? "nil")" },
					entries: entries.map { Self.row(for: $0) }
				)
			}

			return StateSnapshot(reason: reason, kinds: kinds)
		}

		Self.logSummary(snapshot)
		Self.append(snapshot)
	}

	private static func row(for entry: LocalLibraryEntry) -> Row {
		return Row(
			trackable: entry.trackableID,
			status: Int(entry.status),
			favorited: entry.isFavorited ? 1 : 0,
			reminded: entry.isReminded ? 1 : 0,
			hidden: entry.isHidden ? 1 : 0,
			rewatch: Int(entry.rewatchCount),
			score: entry.review?.score?.doubleValue,
			updatedAt: entry.updatedAt.map { Int($0.timeIntervalSince1970) },
			origin: entry.remoteID.hasPrefix(LocalLibraryEntry.localRemoteIDPrefix) ? "L" : "S"
		)
	}

	private static func logSummary(_ snapshot: StateSnapshot) {
		let summary = snapshot.kinds
			.sorted { $0.key < $1.key }
			.map { "kind=\($0.key) count=\($0.value.count) ops=\($0.value.ops) cursor=\($0.value.cursor ?? "nil")" }
			.joined(separator: " | ")
		Self.logger.log("STATE [\(snapshot.reason, privacy: .public)] \(summary, privacy: .public)")
	}

	private static func append(_ snapshot: StateSnapshot) {
		guard let fileURL = Self.fileURL else { return }

		var snapshots = (try? JSONDecoder().decode([StateSnapshot].self, from: Data(contentsOf: fileURL))) ?? []
		snapshots.append(snapshot)
		if snapshots.count > Self.maximumSnapshots {
			snapshots.removeFirst(snapshots.count - Self.maximumSnapshots)
		}

		guard let encoded = try? JSONEncoder().encode(snapshots) else { return }
		try? encoded.write(to: fileURL, options: .atomic)
	}

	private static var fileURL: URL? {
		return FileManager.default
			.urls(for: .documentDirectory, in: .userDomainMask)
			.first?
			.appendingPathComponent(Self.fileName)
	}
}
