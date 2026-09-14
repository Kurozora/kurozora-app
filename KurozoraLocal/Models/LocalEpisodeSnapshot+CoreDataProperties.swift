//
//  LocalEpisodeSnapshot+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

nonisolated extension LocalEpisodeSnapshot {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalEpisodeSnapshot> {
		return NSFetchRequest<LocalEpisodeSnapshot>(entityName: "LocalEpisodeSnapshot")
	}

	/// The account slug this snapshot belongs to.
	@NSManaged var userSlug: String

	/// The identifier of the episode.
	@NSManaged var episodeID: String

	/// The identifier of the show the episode belongs to.
	@NSManaged var trackableID: String

	/// The number of the episode within its season.
	@NSManaged var number: Int64

	/// The number of the episode within its show.
	@NSManaged var numberTotal: Int64

	/// The number of the season the episode belongs to.
	@NSManaged var seasonNumber: Int64

	/// The moment the episode airs.
	@NSManaged var startedAt: Date?

	/// The URL of the episode's banner.
	@NSManaged var bannerURL: String?
}
