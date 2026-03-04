//
//  FeedMessageDraft+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

/// Bundles the fields needed to create or save a draft.
struct DraftRequest {
	let userSlug: String
	let content: String
	let layout: FeedMessageEditorLayout
	let isNSFW: Bool
	let isSpoiler: Bool
	let parentMessage: FeedMessage?
	let editingMessageID: String?
}

@objc(FeedMessageDraft)
class FeedMessageDraft: NSManagedObject {
	// MARK: - Properties
	/// The editor layout for this draft.
	var editorLayout: FeedMessageEditorLayout {
		get { FeedMessageEditorLayout(rawValue: self.editorLayoutRaw) ?? .standard }
		set { self.editorLayoutRaw = newValue.rawValue }
	}

	/// The decoded parent message snapshot, if any.
	var parentSnapshot: FeedMessageSnapshot? {
		get {
			guard let data = self.parentMessageData else { return nil }
			return try? JSONDecoder().decode(FeedMessageSnapshot.self, from: data)
		}
		set {
			self.parentMessageData = newValue.flatMap { try? JSONEncoder().encode($0) }
		}
	}

	// MARK: - Functions
	/// Creates a new draft in the given context.
	///
	/// - Parameters:
	///    - context: The managed object context.
	///    - request: The draft creation request.
	///
	/// - Returns: The newly created draft.
	@discardableResult
	static func create(in context: NSManagedObjectContext, from request: DraftRequest) -> FeedMessageDraft {
		let draft = FeedMessageDraft(context: context)
		draft.uuid = UUID()
		draft.userSlug = request.userSlug
		draft.content = request.content
		draft.editorLayout = request.layout
		draft.isNSFW = request.isNSFW
		draft.isSpoiler = request.isSpoiler
		draft.parentSnapshot = request.parentMessage.map { FeedMessageSnapshot(from: $0) }
		draft.editingMessageID = request.editingMessageID
		draft.createdAt = Date()
		draft.updatedAt = Date()
		return draft
	}

	/// Updates the draft's mutable fields.
	///
	/// - Parameters:
	///   - content: The new text content.
	///   - isNSFW: The new NSFW flag.
	///   - isSpoiler: The new spoiler flag.
	func update(content: String, isNSFW: Bool, isSpoiler: Bool) {
		self.content = content
		self.isNSFW = isNSFW
		self.isSpoiler = isSpoiler
		self.updatedAt = Date()
	}
}
