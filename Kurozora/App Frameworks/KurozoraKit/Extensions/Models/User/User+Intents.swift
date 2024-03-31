//
//  User+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Intents
import KurozoraKit

extension User {
	// MARK: - Properties
	/// Create an NSUserActivity from the selected user.
	public var openDetailUserActivity: NSUserActivity {
		let userActivity = NSUserActivity(activityType: "OpenUserIntent")
		let title = "Visit \(self.attributes.username)’s profile"
		userActivity.title = title
		userActivity.userInfo = ["userID": self.id]
		userActivity.suggestedInvocationPhrase = title
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		return userActivity
	}
}
