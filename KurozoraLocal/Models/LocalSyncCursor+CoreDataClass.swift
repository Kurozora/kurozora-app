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
	/// The stream this cursor tracks.
	var syncStream: LibrarySyncStream? {
		return LibrarySyncStream(rawValue: self.stream)
	}

	/// The opaque cursor the next sync round resumes from.
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
	/// Fetches or creates the cursor row for the given account and stream.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - stream: The sync stream the cursor tracks.
	///    - context: The context to write into.
	///
	/// - Returns: The cursor row.
	static func upsert(forUserSlug userSlug: String, stream: LibrarySyncStream, in context: NSManagedObjectContext) -> LocalSyncCursor {
		if let existing = Self.fetch(forUserSlug: userSlug, stream: stream, in: context) {
			return existing
		}

		let cursor = LocalSyncCursor(context: context)
		cursor.userSlug = userSlug
		cursor.stream = stream.rawValue
		cursor.cursorID = nil
		cursor.cursorUpdatedAt = nil
		cursor.syncedAt = nil
		return cursor
	}

	/// Persists the next-since cursor returned by a sync round.
	///
	/// - Parameter next: The cursor the server returned.
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

	/// Fetches the cursor row matching the given identity.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - stream: The sync stream the cursor tracks.
	///    - context: The context to read from.
	///
	/// - Returns: The matching cursor row.
	static func fetch(forUserSlug userSlug: String, stream: LibrarySyncStream, in context: NSManagedObjectContext) -> LocalSyncCursor? {
		let request = LocalSyncCursor.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@ AND stream == %@", userSlug, stream.rawValue)
		request.fetchLimit = 1
		return try? context.fetch(request).first
	}

	/// The most recent sync date across the account's streams.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - context: The context to read from.
	///
	/// - Returns: The date of the account's most recent sync.
	static func lastSyncedAt(forUserSlug userSlug: String, in context: NSManagedObjectContext) -> Date? {
		let request = LocalSyncCursor.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@ AND syncedAt != nil", userSlug)
		request.sortDescriptors = [NSSortDescriptor(key: "syncedAt", ascending: false)]
		request.fetchLimit = 1
		return try? context.fetch(request).first?.syncedAt
	}
}
