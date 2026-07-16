//
//  LocalLibraryEntryObserver.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import Foundation
import KurozoraKit

/// Bridges save notifications onto a callback fired only for `LocalLibraryEntry` mutations that pass a filter.
final class LocalLibraryEntryObserver {
	// MARK: - Properties
	private var saveToken: NSObjectProtocol?

	// MARK: - Initializers
	/// Subscribes to the save feed and routes each `LocalLibraryEntry` mutation
	/// that matches `filter` through the appropriate callback.
	///
	/// - Parameters:
	///    - filter: Which `(userSlug, kind, trackableID)` tuples to act on.
	///    - onChange: Invoked with the live managed object for inserted/updated entries.
	///    - onRemove: Invoked with a `RemovedEntry` snapshot for deleted entries.
	init(
		matching filter: Filter,
		onChange: @escaping (LocalLibraryEntry) -> Void,
		onRemove: @escaping (RemovedEntry) -> Void = { _ in }
	) {
		let viewContext = PersistenceController.shared.viewContext

		self.saveToken = NotificationCenter.default.addObserver(
			forName: .NSManagedObjectContextDidSave,
			object: nil,
			queue: .main
		) { notification in
			guard let userInfo = notification.userInfo else { return }

			// Merge before dispatch; handlers must read post-save values.
			if let savingContext = notification.object as? NSManagedObjectContext,
			   savingContext !== viewContext,
			   savingContext.persistentStoreCoordinator === viewContext.persistentStoreCoordinator {
				viewContext.mergeChanges(fromContextDidSave: notification)
			}

			// Refresh the overlay cache before dispatch too.
			MainActor.assumeIsolated {
				LibraryStore.shared.refreshOverlayCache(from: notification)
			}

			Self.dispatch(userInfo, viewContext: viewContext, filter: filter, onChange: onChange, onRemove: onRemove)
		}
	}

	deinit {
		if let token = self.saveToken {
			NotificationCenter.default.removeObserver(token)
		}
	}

	// MARK: - Types
	/// Identity filter applied to both inserted/updated and deleted entries.
	struct Filter {
		let userSlug: String
		let kind: LibraryKind?
		/// When non-nil, only entries whose `trackableID` appears in the set match.
		let trackableIDs: Set<String>?

		func matches(userSlug: String, kind: LibraryKind, trackableID: String) -> Bool {
			guard self.userSlug == userSlug else { return false }
			if let expected = self.kind, expected != kind { return false }
			guard let trackableIDs = self.trackableIDs else { return true }
			return trackableIDs.contains(trackableID)
		}
	}

	/// Snapshot of a deleted entry's identity captured before the managed object's context is detached.
	struct RemovedEntry: Hashable {
		let objectID: NSManagedObjectID
		let userSlug: String
		let kind: LibraryKind
		let trackableID: String
	}

	// MARK: - Functions
	private static func dispatch(
		_ userInfo: [AnyHashable: Any],
		viewContext: NSManagedObjectContext,
		filter: Filter,
		onChange: (LocalLibraryEntry) -> Void,
		onRemove: (RemovedEntry) -> Void
	) {
		let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
		let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
		let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []

		for managedObject in updated.union(inserted) {
			guard managedObject is LocalLibraryEntry else { continue }
			guard let entry = Self.resolve(managedObject, in: viewContext) else { continue }
			guard filter.matches(userSlug: entry.userSlug, kind: entry.kind, trackableID: entry.trackableID) else { continue }
			onChange(entry)
		}

		for managedObject in deleted {
			guard managedObject is LocalLibraryEntry else { continue }
			guard let snapshot = Self.snapshot(of: managedObject) else { continue }
			guard let kind = LibraryKind(rawValue: Int(snapshot.kindRaw)) else { continue }
			guard filter.matches(userSlug: snapshot.userSlug, kind: kind, trackableID: snapshot.trackableID) else { continue }
			let removed = RemovedEntry(
				objectID: managedObject.objectID,
				userSlug: snapshot.userSlug,
				kind: kind,
				trackableID: snapshot.trackableID
			)
			onRemove(removed)
		}
	}

	/// Resolves a managed object to its viewContext representation, falling back to
	/// the original instance when no viewContext copy is available.
	private static func resolve(_ managedObject: NSManagedObject, in viewContext: NSManagedObjectContext) -> LocalLibraryEntry? {
		if managedObject.managedObjectContext === viewContext {
			return managedObject as? LocalLibraryEntry
		}
		return viewContext.object(with: managedObject.objectID) as? LocalLibraryEntry
	}

	/// Reads identity fields from a deleted entry via `committedValues(forKeys:)`.
	private static func snapshot(of managedObject: NSManagedObject) -> EntrySnapshot? {
		let values = managedObject.committedValues(forKeys: ["userSlug", "kindRaw", "trackableID"])
		guard let userSlug = values["userSlug"] as? String,
		      let kindRawNumber = values["kindRaw"] as? NSNumber,
		      let trackableID = values["trackableID"] as? String else {
			return nil
		}
		return EntrySnapshot(userSlug: userSlug, kindRaw: kindRawNumber.int64Value, trackableID: trackableID)
	}

	private struct EntrySnapshot {
		let userSlug: String
		let kindRaw: Int64
		let trackableID: String
	}
}

// MARK: - Convenience Filters
extension LocalLibraryEntryObserver {
	/// Convenience filter that matches a single `(userSlug, kind, trackableID)` tuple.
	static func matches(userSlug: String, kind: LibraryKind, trackableID: String) -> Filter {
		return Filter(userSlug: userSlug, kind: kind, trackableIDs: [trackableID])
	}

	/// Convenience filter that matches any entry in the given `(userSlug, kind)` slice.
	static func matches(userSlug: String, kind: LibraryKind) -> Filter {
		return Filter(userSlug: userSlug, kind: kind, trackableIDs: nil)
	}

	/// Convenience filter that matches any entry whose trackable identity appears in the given set.
	static func matches(userSlug: String, kind: LibraryKind, trackableIDs: Set<String>) -> Filter {
		return Filter(userSlug: userSlug, kind: kind, trackableIDs: trackableIDs)
	}

	/// Convenience filter that matches every entry for the user, regardless of kind.
	static func matches(userSlug: String) -> Filter {
		return Filter(userSlug: userSlug, kind: nil, trackableIDs: nil)
	}
}
