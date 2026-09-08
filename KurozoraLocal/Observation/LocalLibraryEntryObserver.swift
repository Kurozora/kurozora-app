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
final class LocalLibraryEntryObserver: NSObject {
	// MARK: - Properties
	private let filter: Filter
	private let onChange: (LocalLibraryEntry) -> Void
	private let onRemove: (RemovedEntry) -> Void
	private let viewContextID: ObjectIdentifier

	// MARK: - Initializers
	/// Subscribes to the save feed and routes each matching `LocalLibraryEntry` mutation through the appropriate callback.
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
		self.filter = filter
		self.onChange = onChange
		self.onRemove = onRemove
		self.viewContextID = ObjectIdentifier(PersistenceController.shared.viewContext)
		super.init()

		NotificationCenter.default.addObserver(self, selector: #selector(self.contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
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

	/// Snapshot of a deleted entry's identity.
	nonisolated struct RemovedEntry: Hashable, Sendable {
		let objectID: NSManagedObjectID
		let userSlug: String
		let kind: LibraryKind
		let trackableID: String

		/// Reads a deleted row's identity from its last committed values.
		///
		/// - Parameter deletedObject: A `LocalLibraryEntry` listed under the deleted objects of a did-save notification.
		init?(deletedObject: NSManagedObject) {
			let values = deletedObject.committedValues(forKeys: ["userSlug", "kindRaw", "trackableID"])
			guard let userSlug = values["userSlug"] as? String,
			      let kindRawNumber = values["kindRaw"] as? NSNumber,
			      let kind = LibraryKind(rawValue: Int(kindRawNumber.int64Value)),
			      let trackableID = values["trackableID"] as? String else {
				return nil
			}

			self.objectID = deletedObject.objectID
			self.userSlug = userSlug
			self.kind = kind
			self.trackableID = trackableID
		}
	}

	// MARK: - Functions
	/// Captures the save on the posting thread.
	@objc nonisolated private func contextDidSave(_ notification: Notification) {
		guard let change = LibraryEntrySaveChange(notification: notification, viewContextID: self.viewContextID) else { return }

		Task { @MainActor in
			self.dispatch(change)
		}
	}

	private func dispatch(_ change: LibraryEntrySaveChange) {
		LibraryStore.shared.refreshOverlayCache(with: change)

		for objectID in change.changedEntryObjectIDs {
			guard let entry = LibraryStore.shared.entry(for: objectID) else { continue }
			guard self.filter.matches(userSlug: entry.userSlug, kind: entry.kind, trackableID: entry.trackableID) else { continue }

			self.onChange(entry)
		}

		for removed in change.removedEntries where self.filter.matches(userSlug: removed.userSlug, kind: removed.kind, trackableID: removed.trackableID) {
			self.onRemove(removed)
		}
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
