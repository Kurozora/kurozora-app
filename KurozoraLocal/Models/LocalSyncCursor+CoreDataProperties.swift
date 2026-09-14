//
//  LocalSyncCursor+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

nonisolated extension LocalSyncCursor {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalSyncCursor> {
		return NSFetchRequest<LocalSyncCursor>(entityName: "LocalSyncCursor")
	}

	/// The account slug this cursor belongs to.
	@NSManaged var userSlug: String

	/// The identifier of the sync stream this cursor tracks.
	@NSManaged var stream: String

	/// The opaque cursor's `updated_at` component.
	@NSManaged var cursorUpdatedAt: String?

	/// The opaque cursor's `id` component.
	@NSManaged var cursorID: String?

	/// The server wall-clock embedded into the cursor on the previous response.
	@NSManaged var syncedAt: Date?
}
