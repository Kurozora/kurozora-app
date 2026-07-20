//
//  LocalSyncCursor+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

extension LocalSyncCursor {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalSyncCursor> {
		return NSFetchRequest<LocalSyncCursor>(entityName: "LocalSyncCursor")
	}

	/// The account slug this cursor belongs to.
	@NSManaged var userSlug: String

	/// Raw value of `LibraryKind`.
	@NSManaged var kindRaw: Int64

	/// The opaque cursor's `updated_at` component, echoed to the server verbatim,
	/// or `nil` for initial sync.
	@NSManaged var cursorUpdatedAt: String?

	/// The opaque cursor's `id` component, or `nil` for initial sync.
	@NSManaged var cursorID: String?

	/// The server wall-clock embedded into the cursor on the previous response.
	@NSManaged var syncedAt: Date?
}
