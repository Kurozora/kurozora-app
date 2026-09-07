//
//  LocalOutboxOperation+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

extension LocalOutboxOperation {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalOutboxOperation> {
		return NSFetchRequest<LocalOutboxOperation>(entityName: "LocalOutboxOperation")
	}

	/// The operation's unique identifier.
	@NSManaged var id: UUID

	/// The account slug this operation belongs to.
	@NSManaged var userSlug: String

	/// Raw value of `LibraryKind`.
	@NSManaged var kindRaw: Int64

	/// The identifier of the trackable model (anime/manga/game), empty for episode/season operations.
	@NSManaged var trackableID: String

	/// The identifier of the episode/season targeted by a watch-status operation, empty otherwise.
	@NSManaged var targetID: String

	/// Raw value of `LibraryOutboxOperationType`.
	@NSManaged var operationTypeRaw: Int16

	/// The encoded `LibraryOutboxPayload`, if the operation type carries one.
	@NSManaged var payload: Data?

	/// The encoded `LibraryOutboxSeed`, present only on an offline `setStatus` that created its row.
	@NSManaged var seed: Data?

	/// The date the operation was enqueued.
	@NSManaged var createdAt: Date

	/// The number of failed flush attempts.
	@NSManaged var attemptCount: Int16

	/// The date of the last failed flush attempt, or `nil` if none has failed yet.
	@NSManaged var lastAttemptAt: Date?

	/// The message of the last failed flush attempt, or `nil` if none has failed yet.
	@NSManaged var lastError: String?
}
