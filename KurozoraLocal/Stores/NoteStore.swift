//
//  NoteStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

/// The local store of the user's private notes.
///
/// A note is keyed by account, kind and item, and belongs to no library entry.
@MainActor
final class NoteStore {
	// MARK: - Properties
	static let shared = NoteStore()

	private var viewContext: NSManagedObjectContext {
		return PersistenceController.shared.container.viewContext
	}

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns the stored note on the given item.
	///
	/// - Parameters:
	///    - itemID: The identifier of the annotated item.
	///    - userSlug: The account slug owning the note.
	///    - kind: The kind of the annotated item.
	///
	/// - Returns: The note, or `nil` when the item carries none.
	func note(for itemID: String, userSlug: String, kind: ReviewKind) -> String? {
		return LocalNote.fetch(itemID: itemID, userSlug: userSlug, kind: kind, in: self.viewContext)?.body
	}

	/// Writes a note to the local store, removing it when the body is empty.
	///
	/// - Parameters:
	///    - body: The note to store.
	///    - itemID: The identifier of the annotated item.
	///    - userSlug: The account slug owning the note.
	///    - kind: The kind of the annotated item.
	func apply(_ body: String?, itemID: String, userSlug: String, kind: ReviewKind) {
		LocalNote.apply(body, itemID: itemID, userSlug: userSlug, kind: kind, in: self.viewContext)
		PersistenceController.shared.save(self.viewContext)
	}

	/// Removes every stored note belonging to the given account.
	///
	/// - Parameter userSlug: The account slug whose notes to remove.
	func clear(forUserSlug userSlug: String) {
		let request = LocalNote.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@", userSlug)

		guard let notes = try? self.viewContext.fetch(request) else { return }

		notes.forEach { self.viewContext.delete($0) }
		PersistenceController.shared.save(self.viewContext)
	}
}
