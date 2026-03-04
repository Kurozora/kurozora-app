//
//  DraftStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

/// Manages CRUD operations for feed message drafts via Core Data.
final class DraftStore {
	// MARK: - Properties
	/// Returns the singleton `DraftStore` instance.
	static let shared = DraftStore()

	private var viewContext: NSManagedObjectContext {
		return PersistenceController.shared.viewContext
	}

	// MARK: - Initializers
	private init() {}

	// MARK: - Read
	/// Returns all drafts for the given account, sorted by most recently updated.
	///
	/// - Parameter slug: The user's account slug.
	///
	/// - Returns: An array of `FeedMessageDraft` sorted newest-first.
	func drafts(forUserSlug slug: String) -> [FeedMessageDraft] {
		let request = FeedMessageDraft.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@", slug)
		request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

		do {
			return try self.viewContext.fetch(request)
		} catch {
			print("----- [DraftStore] Fetch failed:", error.localizedDescription)
			return []
		}
	}

	/// Returns the number of drafts for the given account.
	///
	/// - Parameter slug: The user's account slug.
	///
	/// - Returns: The draft count.
	func draftCount(forUserSlug slug: String) -> Int {
		let request = FeedMessageDraft.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@", slug)

		do {
			return try self.viewContext.count(for: request)
		} catch {
			print("----- [DraftStore] Count failed:", error.localizedDescription)
			return 0
		}
	}

	/// Fetches a single draft by its UUID.
	///
	/// - Parameter uuid: The draft's unique identifier.
	///
	/// - Returns: The draft, or nil if not found.
	func draft(withUUID uuid: UUID) -> FeedMessageDraft? {
		let request = FeedMessageDraft.fetchRequest()
		request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
		request.fetchLimit = 1

		return try? self.viewContext.fetch(request).first
	}

	// MARK: - Write
	/// Creates and persists a new draft.
	///
	/// - Parameter request: The draft creation request.
	///
	/// - Returns: The UUID of the newly created draft.
	@discardableResult
	func saveDraft(_ request: DraftRequest) -> UUID {
		let draft = FeedMessageDraft.create(in: self.viewContext, from: request)
		PersistenceController.shared.save(self.viewContext)
		return draft.uuid
	}

	/// Updates an existing draft's mutable fields.
	///
	/// - Parameters:
	///   - uuid: The draft's UUID.
	///   - content: The new text content.
	///   - isNSFW: The new NSFW flag.
	///   - isSpoiler: The new spoiler flag.
	func updateDraft(uuid: UUID, content: String, isNSFW: Bool, isSpoiler: Bool) {
		guard let draft = self.draft(withUUID: uuid) else { return }
		draft.update(content: content, isNSFW: isNSFW, isSpoiler: isSpoiler)
		PersistenceController.shared.save(self.viewContext)
	}

	// MARK: - Delete
	/// Deletes a draft by its UUID.
	///
	/// - Parameter uuid: The draft's unique identifier.
	func deleteDraft(uuid: UUID) {
		guard let draft = self.draft(withUUID: uuid) else { return }
		self.viewContext.delete(draft)
		PersistenceController.shared.save(self.viewContext)
	}

	/// Deletes all drafts for the given account.
	///
	/// - Parameter slug: The user's account slug.
	func deleteAll(forUserSlug slug: String) {
		let drafts = self.drafts(forUserSlug: slug)
		for draft in drafts {
			self.viewContext.delete(draft)
		}
		PersistenceController.shared.save(self.viewContext)
	}
}
