//
//  NSUserActivity+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/11/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation

/// Activity types used throughout the Kurozora app.
enum ActivityType: String {
	/// Activity type for opening a show detail.
	case openShow = "app.kurozora.tracker.user-activity.openShow"
	/// Activity type for opening a literature detail.
	case openLiterature = "app.kurozora.tracker.user-activity.openLiterature"
	/// Activity type for opening a game detail.
	case openGame = "app.kurozora.tracker.user-activity.openGame"
	/// Activity type for opening a user profile.
	case openUser = "app.kurozora.tracker.user-activity.openUser"
}

extension NSUserActivity {
	/// Creates a user activity object with the specified type.
	///
	/// - Parameter activityType: The type of the activity. The value is a developer-defined string in reverse-DNS format by convention, for example, `com.myCompany.myEditor.editing`.
	///
	/// - Returns: An [NSUserActivity](https://developer.apple.com/documentation/foundation/nsuseractivity) object.
	convenience init(activityType: ActivityType) {
		self.init(activityType: activityType.rawValue)
	}
}
