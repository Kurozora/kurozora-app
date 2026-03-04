//
//  FeedMessageDraft+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

extension FeedMessageDraft {
	@nonobjc class func fetchRequest() -> NSFetchRequest<FeedMessageDraft> {
		return NSFetchRequest<FeedMessageDraft>(entityName: "FeedMessageDraft")
	}

	/// Unique identifier for this draft.
	@NSManaged var uuid: UUID

	/// The account slug this draft belongs to.
	@NSManaged var userSlug: String

	/// The draft body text.
	@NSManaged var content: String

	/// Raw value of `FeedMessageEditorLayout`.
	@NSManaged var editorLayoutRaw: Int

	/// Whether the draft is flagged as NSFW.
	@NSManaged var isNSFW: Bool

	/// Whether the draft is flagged as a spoiler.
	@NSManaged var isSpoiler: Bool

	/// JSON-encoded `FeedMessageSnapshot` for reply/reshare parent context.
	@NSManaged var parentMessageData: Data?

	/// Server ID of the message being edited. Non-nil indicates an edit draft.
	@NSManaged var editingMessageID: String?

	/// The date this draft was created.
	@NSManaged var createdAt: Date

	/// The date this draft was last updated.
	@NSManaged var updatedAt: Date
}

extension FeedMessageDraft: Identifiable {
	public var id: UUID {
		return self.uuid
	}
}
