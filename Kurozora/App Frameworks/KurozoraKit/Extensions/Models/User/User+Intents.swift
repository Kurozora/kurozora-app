//
//  User+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import CoreSpotlight
import Intents
import MobileCoreServices
import KurozoraKit

extension User {
	// MARK: - Properties
	/// Create an NSUserActivity from the selected user.
	public var openDetailUserActivity: NSUserActivity {
		let userActivity = NSUserActivity(activityType: "OpenUserIntent")
		let title = "Open \(self.attributes.username)’s profile"
		userActivity.contentAttributeSet = self.contentAttributeSet
		userActivity.title = self.attributes.username
		userActivity.userInfo = ["userID": self.id]
		userActivity.suggestedInvocationPhrase = title
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		userActivity.isEligibleForHandoff = true
		userActivity.persistentIdentifier = "\(self.type):\(self.id)"
		return userActivity
	}

	/// The detailed metadata for making the selected literature searchable.
	public var contentAttributeSet: CSSearchableItemAttributeSet {
		let attributeSet = CSSearchableItemAttributeSet(contentType: .contact)
		attributeSet.title = self.attributes.username
		attributeSet.contentDescription = self.attributes.biography
		if let urlString = self.attributes.profile?.url {
			attributeSet.thumbnailURL = URL(string: urlString)
		}
		attributeSet.startDate = self.attributes.joinedAt
		attributeSet.accountIdentifier = "@\(self.attributes.slug)"
		attributeSet.url = URL(string: "https://kurozora.app/profile/\(self.attributes.slug)")
		return attributeSet
	}
}
