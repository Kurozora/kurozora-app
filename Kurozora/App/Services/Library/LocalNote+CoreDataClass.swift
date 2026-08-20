//
//  LocalNote+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalNote)
class LocalNote: NSManagedObject {
	// MARK: - Properties
	/// The kind of item the note is attached to.
	var kind: ReviewKind? {
		get { ReviewKind(rawValue: Int(self.kindRaw)) }
		set { self.kindRaw = Int64(newValue?.rawValue ?? 0) }
	}

	// MARK: - Functions
	/// Returns the note the given account wrote on the given item.
	///
	/// - Parameters:
	///    - itemID: The identifier of the annotated item.
	///    - userSlug: The account slug owning the note.
	///    - kind: The kind of the annotated item.
	///    - context: The managed object context.
	///
	/// - Returns: The stored note, or `nil` when the item carries none.
	static func fetch(itemID: String, userSlug: String, kind: ReviewKind, in context: NSManagedObjectContext) -> LocalNote? {
		let request = Self.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d AND itemID == %@",
			userSlug, kind.rawValue, itemID
		)
		request.fetchLimit = 1

		return try? context.fetch(request).first
	}

	/// Writes an overlay entry's note, removing the stored note when the body is empty.
	///
	/// - Parameters:
	///    - body: The note carried by the overlay entry.
	///    - itemID: The identifier of the annotated item.
	///    - userSlug: The account slug owning the note.
	///    - kind: The kind of the annotated item.
	///    - context: The managed object context.
	@discardableResult
	static func apply(_ body: String?, itemID: String, userSlug: String, kind: ReviewKind, in context: NSManagedObjectContext) -> LocalNote? {
		let existing = Self.fetch(itemID: itemID, userSlug: userSlug, kind: kind, in: context)

		guard let body = body, !body.isEmpty else {
			if let existing = existing {
				context.delete(existing)
			}

			return nil
		}

		let note = existing ?? LocalNote(context: context)
		note.userSlug = userSlug
		note.kindRaw = Int64(kind.rawValue)
		note.itemID = itemID
		note.body = body

		return note
	}
}
