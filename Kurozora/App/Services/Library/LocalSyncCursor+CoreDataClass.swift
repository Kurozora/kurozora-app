//
//  LocalSyncCursor+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalSyncCursor)
class LocalSyncCursor: NSManagedObject {
	// MARK: - Properties
	/// The library kind this cursor tracks.
	var kind: LibraryKind {
		get { LibraryKind(rawValue: Int(self.kindRaw)) ?? .shows }
		set { self.kindRaw = Int64(newValue.rawValue) }
	}

	/// The opaque cursor the next sync should resume from, or `nil` for initial sync.
	var syncCursor: SyncCursor? {
		guard let updatedAt = self.cursorUpdatedAt, let id = self.cursorID else { return nil }
		let syncedAtTimestamp = (self.syncedAt ?? Date()).timeIntervalSince1970
		return SyncCursor(
			updatedAt: updatedAt,
			id: id,
			syncedAt: Int(syncedAtTimestamp)
		)
	}

	// MARK: - Functions
	/// Fetches or creates the cursor row for the given (userSlug, kind), seeding defaults.
	static func upsert(forUserSlug userSlug: String, kind: LibraryKind, in context: NSManagedObjectContext) -> LocalSyncCursor {
		if let existing = Self.fetch(forUserSlug: userSlug, kind: kind, in: context) {
			return existing
		}

		let cursor = LocalSyncCursor(context: context)
		cursor.userSlug = userSlug
		cursor.kindRaw = Int64(kind.rawValue)
		cursor.cursorID = nil
		cursor.cursorUpdatedAt = nil
		cursor.syncedAt = nil
		return cursor
	}

	/// Persists the next-since cursor returned by a sync batch.
	func advance(to next: SyncCursor?) {
		self.cursorID = next.map { $0.id }
		self.cursorUpdatedAt = next.map { $0.updatedAt }
		self.syncedAt = next.map { cursor in
			if let serverSyncedAt = cursor.syncedAt {
				return Date(timeIntervalSince1970: TimeInterval(serverSyncedAt))
			}
			return Date()
		}
	}

	/// Fetches the cursor row matching the given identity, if present.
	static func fetch(forUserSlug userSlug: String, kind: LibraryKind, in context: NSManagedObjectContext) -> LocalSyncCursor? {
		let request = LocalSyncCursor.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@ AND kindRaw == %d", userSlug, Int64(kind.rawValue))
		request.fetchLimit = 1
		return try? context.fetch(request).first
	}
}
