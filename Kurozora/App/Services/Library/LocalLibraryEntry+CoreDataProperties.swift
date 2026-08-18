//
//  LocalLibraryEntry+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

extension LocalLibraryEntry {
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

	/// The trackable's URL-safe slug, used to build canonical webpage links.
	@NSManaged var slug: String?

	/// The renderable title for the trackable, localised to the request's locale.
	@NSManaged var title: String?

	/// The locale-stable sort key for alphabetical ordering.
	@NSManaged var sortTitle: String?

	/// The trackable's tagline, or `nil` if absent.
	@NSManaged var tagline: String?

	/// The poster image URL, or `nil` if no poster exists.
	@NSManaged var posterURL: String?

	/// The poster placeholder background color, as a hex string.
	@NSManaged var posterBackgroundColor: String?

	/// The banner image URL, or `nil` if no banner exists.
	@NSManaged var bannerURL: String?

	/// The banner placeholder background color, as a hex string.
	@NSManaged var bannerBackgroundColor: String?

	/// The trackable's genres pre-joined into a localised display string.
	@NSManaged var genresLocalized: String?

	/// The trackable's status name (e.g. "Currently Airing"), localised.
	@NSManaged var statusName: String?

	/// The next broadcast or publication date, used for the on-cell countdown.
	@NSManaged var airingDate: Date?

	/// The countdown duration in seconds.
	@NSManaged var durationCount: NSNumber?

	/// The localised media-type label (e.g. "TV", "Movie", "Novel").
	@NSManaged var mediaTypeName: String?

	/// The popularity ranking of the trackable, lower is more popular.
	@NSManaged var popularityRank: NSNumber?

	/// The public average rating, used for the rating sort axis.
	@NSManaged var publicRating: NSNumber?

	/// The user's review of the trackable.
	@NSManaged var review: LocalReview?
}
