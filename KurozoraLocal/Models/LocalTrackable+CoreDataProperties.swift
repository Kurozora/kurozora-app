//
//  LocalTrackable+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

nonisolated extension LocalTrackable {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalTrackable> {
		return NSFetchRequest<LocalTrackable>(entityName: "LocalTrackable")
	}

	/// Raw value of `LibraryKind`.
	@NSManaged var kindRaw: Int64

	/// The server-side primary key of the show, literature or game.
	@NSManaged var trackableID: String

	/// The trackable's slug.
	@NSManaged var slug: String?

	/// The trackable's title.
	@NSManaged var title: String?

	/// The sort key derived from the title.
	@NSManaged var sortTitle: String?

	/// The trackable's tagline.
	@NSManaged var tagline: String?

	/// The source URL of the trackable's poster.
	@NSManaged var posterURL: String?

	/// The color behind the trackable's poster.
	@NSManaged var posterBackgroundColor: String?

	/// The source URL of the trackable's banner.
	@NSManaged var bannerURL: String?

	/// The color behind the trackable's banner.
	@NSManaged var bannerBackgroundColor: String?

	/// The trackable's genres in the user's language.
	@NSManaged var genresLocalized: String?

	/// The identifier of the trackable's media type.
	@NSManaged var mediaTypeID: NSNumber?

	/// The localized name of the trackable's media type.
	@NSManaged var mediaTypeName: String?

	/// The identifier of the trackable's airing or publishing status.
	@NSManaged var statusID: NSNumber?

	/// The name of the trackable's airing or publishing status.
	@NSManaged var statusName: String?

	/// The trackable's next broadcast.
	@NSManaged var airingDate: Date?

	/// The time of day the trackable airs or publishes in Japan.
	@NSManaged var airTime: String?

	/// The trackable's duration in seconds.
	@NSManaged var durationCount: NSNumber?

	/// The trackable's popularity ranking.
	@NSManaged var popularityRank: NSNumber?

	/// The trackable's public average rating.
	@NSManaged var publicRating: NSNumber?

	/// The identifier of the trackable's TV rating.
	@NSManaged var tvRatingID: NSNumber?

	/// The identifier of the trackable's adaptation source.
	@NSManaged var sourceID: NSNumber?

	/// The two-letter code of the trackable's country of origin.
	@NSManaged var countryOfOrigin: String?

	/// Whether the trackable is marked not safe for work.
	@NSManaged var isNSFW: NSNumber?

	/// The weekday the trackable airs or publishes on.
	@NSManaged var scheduleDay: NSNumber?

	/// The season of the year the trackable airs or publishes in.
	@NSManaged var scheduleSeason: NSNumber?

	/// The number of episodes, chapters or editions the trackable has.
	@NSManaged var episodeCount: NSNumber?

	/// The number of seasons or volumes the trackable has.
	@NSManaged var seasonCount: NSNumber?

	/// The date the trackable first aired or published.
	@NSManaged var firstAired: Date?

	/// The date the trackable last aired or published.
	@NSManaged var lastAired: Date?

	/// The library entries pointing at the trackable.
	@NSManaged var entries: NSSet?
}
