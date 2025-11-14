//
//  Literature+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import CoreSpotlight
import Intents
import KurozoraKit
import MobileCoreServices

extension Literature {
	// MARK: - Properties
	/// Create an NSUserActivity from the selected literature.
	var openDetailUserActivity: NSUserActivity {
		let userActivity = NSUserActivity(activityType: .openLiterature)
		let title = "Open \(self.attributes.title)"
		userActivity.contentAttributeSet = self.contentAttributeSet
		userActivity.title = self.attributes.title
		try? userActivity.setTypedPayload(["id": self.id])
		userActivity.requiredUserInfoKeys = ["id"]
		userActivity.suggestedInvocationPhrase = title
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		userActivity.isEligibleForHandoff = true
		userActivity.isEligibleForPublicIndexing = true
		userActivity.webpageURL = URL(string: "https://kurozora.app/manga/\(self.attributes.slug)")
		userActivity.persistentIdentifier = "\(self.type):\(self.id)"
		return userActivity
	}

	/// The detailed metadata for making the selected literature searchable.
	var contentAttributeSet: CSSearchableItemAttributeSet {
		let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
		attributeSet.title = self.attributes.title
		attributeSet.alternateNames = self.attributes.synonymTitles
		attributeSet.contentDescription = self.attributes.synopsis
		attributeSet.keywords = [self.attributes.title] + (self.attributes.synonymTitles ?? []) + (self.attributes.genres ?? []) + (self.attributes.themes ?? [])
		if let urlString = self.attributes.poster?.url {
			attributeSet.thumbnailURL = URL(string: urlString)
		}
		attributeSet.genre = self.attributes.genres?.joined(separator: ", ")
		attributeSet.theme = self.attributes.themes?.joined(separator: ", ")
		attributeSet.audiences = [self.attributes.tvRating.name]
		attributeSet.rating = self.attributes.stats?.ratingAverage as? NSNumber
		if let ratingDescription = self.attributes.stats?.ratingCount {
			attributeSet.ratingDescription = "\(ratingDescription.kkFormatted(precision: 0)) Ratings"
		}
		attributeSet.startDate = self.attributes.startedAt
		attributeSet.endDate = self.attributes.endedAt
		attributeSet.copyright = self.attributes.copyright
		attributeSet.url = URL(string: "https://kurozora.app/manga/\(self.attributes.slug)")
		attributeSet.domainIdentifier = self.type
		return attributeSet
	}
}
