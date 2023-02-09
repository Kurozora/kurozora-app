//
//  Show+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Intents
import KurozoraKit

extension Show {
	// MARK: - Properties
	/// Create an NSUserActivity from the selected show.
	public var openDetailUserActivity: NSUserActivity {
		let userActivity = NSUserActivity(activityType: "OpenShowIntent")
		let title = "Open \(self.attributes.title)"
		userActivity.title = title
		userActivity.userInfo = ["showID": self.id]
		userActivity.suggestedInvocationPhrase = title
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		return userActivity
	}
}
