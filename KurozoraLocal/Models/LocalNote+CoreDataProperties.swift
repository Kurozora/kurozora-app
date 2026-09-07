//
//  LocalNote+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

extension LocalNote {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalNote> {
		return NSFetchRequest<LocalNote>(entityName: "LocalNote")
	}

	/// The note the user wrote.
	@NSManaged var body: String?

	/// The date the note was first written server-side.
	@NSManaged var createdAt: Date?

	/// The identifier of the annotated item.
	@NSManaged var itemID: String?

	/// Raw value of `ReviewKind`.
	@NSManaged var kindRaw: Int64

	/// The date the note was last edited server-side.
	@NSManaged var updatedAt: Date?

	/// The slug of the account the note belongs to.
	@NSManaged var userSlug: String?
}
