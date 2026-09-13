//
//  LocalLibraryEntry+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

nonisolated extension LocalLibraryEntry {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalLibraryEntry> {
		return NSFetchRequest<LocalLibraryEntry>(entityName: "LocalLibraryEntry")
	}

	/// The account slug this entry belongs to.
	@NSManaged var userSlug: String

	/// Raw value of `LibraryKind`.
	@NSManaged var kindRaw: Int64

	/// The server-side primary identifier for this row.
	@NSManaged var remoteID: String

	/// The identifier of the trackable model (anime/manga/game).
	@NSManaged var trackableID: String

	/// Raw value of `LibraryStatus`.
	@NSManaged var status: Int64

	/// The number of times the user has rewatched the trackable.
	@NSManaged var rewatchCount: Int64

	/// Whether the entry is hidden from public views of the user's library.
	@NSManaged var isHidden: Bool

	/// The date the user started consuming the trackable.
	@NSManaged var startedAt: Date?

	/// The date the user finished consuming the trackable.
	@NSManaged var endedAt: Date?

	/// The date the entry was first created server-side.
	@NSManaged var createdAt: Date?

	/// The date the entry was last touched server-side.
	@NSManaged var updatedAt: Date?

	/// The date the entry was soft-deleted server-side, or `nil` for live rows.
	@NSManaged var deletedAt: Date?

	/// Whether the user has favorited the trackable.
	@NSManaged var isFavorited: Bool

	/// The date the user favorited the trackable.
	@NSManaged var favoritedAt: Date?

	/// Whether the user has set a reminder on the trackable.
	@NSManaged var isReminded: Bool

	/// The date the user set the reminder.
	@NSManaged var remindedAt: Date?

	/// The user's review of the trackable.
	@NSManaged var review: LocalReview?

	/// The show, literature or game the entry tracks.
	@NSManaged var trackable: LocalTrackable?
}
