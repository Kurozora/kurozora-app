//
//  LocalReview+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalReview)
class LocalReview: NSManagedObject {
	// MARK: - Properties
	/// The reviewer's recommendation.
	var reviewRecommendation: ReviewRecommendation? {
		get { self.recommendation.flatMap { ReviewRecommendation(rawValue: $0.intValue) } }
		set { self.recommendation = newValue.map { NSNumber(value: $0.rawValue) } }
	}

	// MARK: - Functions
	/// Writes a sync delta row's review onto the given entry, removing the review when the row has none.
	///
	/// - Parameters:
	///    - review: The review carried by the sync delta row.
	///    - entry: The entry the review belongs to.
	///    - context: The managed object context.
	static func apply(_ review: LibrarySyncReviewEntry?, to entry: LocalLibraryEntry, in context: NSManagedObjectContext) {
		guard let review = review else {
			if let existing = entry.review {
				context.delete(existing)
			}

			return
		}

		let localReview = entry.review ?? LocalReview(context: context)
		localReview.entry = entry
		localReview.remoteID = review.id
		localReview.score = NSNumber(value: review.score)
		localReview.text = review.description
		localReview.note = review.note
		localReview.isSpoiler = NSNumber(value: review.isSpoiler)
		localReview.reviewRecommendation = review.recommendation
		localReview.createdAt = review.createdAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		localReview.updatedAt = review.updatedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
	}
}
