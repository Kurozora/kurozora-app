//
//  LibraryEntrySaveChange.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

nonisolated struct LibraryEntrySaveChange: Sendable {
	// MARK: - Properties
	/// The identifiers of the `LocalLibraryEntry` rows the save inserted or updated.
	let changedEntryObjectIDs: [NSManagedObjectID]

	/// The identities of the `LocalLibraryEntry` rows the save deleted.
	let removedEntries: [LocalLibraryEntryObserver.RemovedEntry]

	private let insertedObjectIDs: [NSManagedObjectID]
	private let updatedObjectIDs: [NSManagedObjectID]
	private let deletedObjectIDs: [NSManagedObjectID]
	private let isSavedByViewContext: Bool

	// MARK: - Initializers
	/// Captures the save a did-save notification describes.
	///
	/// - Parameters:
	///    - notification: The `NSManagedObjectContextDidSave` notification.
	///    - viewContextID: The identity of the main-queue context the change is later merged into.
	init?(notification: Notification, viewContextID: ObjectIdentifier) {
		guard let savingContext = notification.object as? NSManagedObjectContext, let userInfo = notification.userInfo else { return nil }

		let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
		let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
		let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []

		let changedEntryObjectIDs = inserted.union(updated)
			.filter { $0 is LocalLibraryEntry }
			.map(\.objectID)
		let removedEntries = deleted
			.filter { $0 is LocalLibraryEntry }
			.compactMap(LocalLibraryEntryObserver.RemovedEntry.init(deletedObject:))
		guard !changedEntryObjectIDs.isEmpty || !removedEntries.isEmpty else { return nil }

		self.changedEntryObjectIDs = changedEntryObjectIDs
		self.removedEntries = removedEntries
		self.insertedObjectIDs = inserted.map(\.objectID)
		self.updatedObjectIDs = updated.map(\.objectID)
		self.deletedObjectIDs = deleted.map(\.objectID)
		self.isSavedByViewContext = ObjectIdentifier(savingContext) == viewContextID
	}

	// MARK: - Functions
	/// Brings the view context up to date with the save, so readers see post-save values.
	///
	/// - Parameter viewContext: The main-queue context to merge into.
	@MainActor
	func merge(into viewContext: NSManagedObjectContext) {
		guard !self.isSavedByViewContext else { return }

		NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [
			NSInsertedObjectsKey: self.insertedObjectIDs,
			NSUpdatedObjectsKey: self.updatedObjectIDs,
			NSDeletedObjectsKey: self.deletedObjectIDs
		], into: [viewContext])
	}
}
