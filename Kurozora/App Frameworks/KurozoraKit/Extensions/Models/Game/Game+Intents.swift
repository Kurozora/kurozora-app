//
//  Game+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Intents
import KurozoraKit

extension Game {
	// MARK: - Properties
	/// Create an NSUserActivity from the selected show.
	public var openDetailUserActivity: NSUserActivity {
		let userActivity = NSUserActivity(activityType: "OpenGameIntent")
		let title = "Open \(self.attributes.title)"
		userActivity.title = title
		userActivity.userInfo = ["gameID": self.id]
		userActivity.suggestedInvocationPhrase = title
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		return userActivity
	}
}
