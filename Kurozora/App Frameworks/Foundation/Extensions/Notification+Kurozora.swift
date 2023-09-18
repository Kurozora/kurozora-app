//
//  Notification+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

// MARK: - Subscription
extension Notification.Name {
	/// A notification posted when the user's subscription status changes.
	static var KSubscriptionStatusDidUpdate: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - Episodes
extension Notification.Name {
	/// A notification posted when the watch status of an episode changes.
	static var KEpisodeWatchStatusDidUpdate: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - Seasons
extension Notification.Name {
	/// A notification posted when the watch status of an season changes.
	static var KSeasonWatchStatusDidUpdate: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - Shows
extension Notification.Name {
	/// A notification posted when the favorites list changes.
	static var KFavoriteModelsListDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted when the favorite button is toggled.
	static var KModelFavoriteIsToggled: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted when the reminder button is toggled.
	static var KModelReminderIsToggled: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - Feed
extension Notification.Name {
	/// A notification posted when the feed message is updated.
	static var KFMDidUpdate: NSNotification.Name {
		return NSNotification.Name(#function)
	}

	/// A notification posted when the feed message is deleted.
	static var KFMDidDelete: NSNotification.Name {
		return NSNotification.Name(#function)
	}
}

// MARK: - Notifications
extension Notification.Name {
	/// A notification posted when the user notifications are updated.
	static var KUNDidUpdate: NSNotification.Name {
		return NSNotification.Name(#function)
	}

	/// A notification posted when the user notification is deleted.
	static var KUNDidDelete: NSNotification.Name {
		return NSNotification.Name(#function)
	}
}

// MARK: - Notification settings
extension Notification.Name {
	/// A notification posted after the value of `notificationsBadge` in `UserSettings` has changed.
	static var KSNotificationsBadgeIsOn: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted after the value of notification options in `UserSettings` has changed.
	static var KSNotificationOptionsValueLabelsNotification: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - App settings
extension Notification.Name {
	/// A notification posted after the value of `appearance` options in `UserSettings` has changed.
	static var KSAppAppearanceDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted after the value of `appIcon` in `UserSettings` has changed.
	static var KSAppIconDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification poster after the value of `prefersLargeTitles` in `UserSettings` has changes.
	static var KSPrefersLargeTitlesDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - User settings
extension Notification.Name {
	/// A notification posted after the value of `authenticationInterval` in `UserSettings` has changed.
	static var KSAuthenticationRequireTimeoutValueDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - Session settings
extension Notification.Name {
	/// A notification posted after a session is deleted.
	static var KSSessionIsDeleted: NSNotification.Name {
		return Notification.Name(#function)
	}
}

// MARK: - Theme settings
extension Notification.Name {
	/// A notification posted after the value of selected theme has changed.
	static var ThemeUpdateNotification: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted after the value of `darkThemeOption` in `UserSettings` has changed.
	static var KSAutomaticDarkThemeDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
}
