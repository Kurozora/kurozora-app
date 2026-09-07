//
//  LocalReview+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

extension LocalReview {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalReview> {
		return NSFetchRequest<LocalReview>(entityName: "LocalReview")
	}

	/// The server-side primary identifier for this review.
	@NSManaged var remoteID: String?

	/// The score the user gave, from `0` to `5`.
	@NSManaged var score: NSNumber?

	/// The written review. Named `text` because `description` is taken by `NSObject`.
	@NSManaged var text: String?

	/// The user's private note on the item.
	@NSManaged var note: String?

	/// Whether the review contains spoiler material.
	@NSManaged var isSpoiler: NSNumber?

	/// Raw value of `ReviewRecommendation`.
	@NSManaged var recommendation: NSNumber?

	/// The date the review was first created server-side.
	@NSManaged var createdAt: Date?

	/// The date the review was last edited server-side.
	@NSManaged var updatedAt: Date?

	/// The library entry the review belongs to.
	@NSManaged var entry: LocalLibraryEntry?
}
