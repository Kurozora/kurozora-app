//
//  Game+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import CoreSpotlight
import Intents
import MobileCoreServices
import KurozoraKit

extension Game {
	// MARK: - Properties
	/// Create an NSUserActivity from the selected game.
	public var openDetailUserActivity: NSUserActivity {
		let userActivity = NSUserActivity(activityType: "OpenGameIntent")
		let title = "Open \(self.attributes.title)"
		userActivity.contentAttributeSet = self.contentAttributeSet
		userActivity.title = self.attributes.title
		userActivity.userInfo = ["gameID": self.id]
		userActivity.suggestedInvocationPhrase = title
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		userActivity.isEligibleForHandoff = true
		userActivity.isEligibleForPublicIndexing = true
		userActivity.persistentIdentifier = "\(self.type):\(self.id)"
		return userActivity
	}

	/// The detailed metadata for making the selected game searchable.
	public var contentAttributeSet: CSSearchableItemAttributeSet {
		let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
		attributeSet.title = self.attributes.title
		attributeSet.alternateNames = self.attributes.synonymTitles
		attributeSet.contentDescription = self.attributes.synopsis
		attributeSet.thumbnailURL = URL(string: self.attributes.poster?.url)
		attributeSet.genre = self.attributes.genres?.joined(separator: ", ")
		attributeSet.rating = self.attributes.stats?.ratingAverage as? NSNumber
		if let ratingDescription = self.attributes.stats?.ratingCount {
			attributeSet.ratingDescription = "\(ratingDescription.kkFormatted) Ratings"
		}
		attributeSet.startDate = self.attributes.startedAt
		attributeSet.endDate = self.attributes.endedAt
		attributeSet.copyright = self.attributes.copyright
		attributeSet.url = URL(string: "https://kurozora.app/games/\(self.attributes.slug)")
		return attributeSet
	}
}
