//
//  Notification+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension Notification.Name {
	// MARK: - Shows
	/// A notification posted when the favorite shows list changes.
	static var KFavoriteShowsListDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - Notification settings
	/// A notification posted after the value of `notificationsBadge` in `UserSettings` has changed.
	static var KSNotificationsBadgeIsOn: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted after the value of notification options in `UserSettings` has changed.
	static var KSNotificationOptionsValueLabelsNotification: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - App settings
	/// A notification posted after the value of appearance options in `UserSettings` has changed.
	static var KSAppAppearanceDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted after the value of `appIcon` in `UserSettings` has changed.
	static var KSAppIconDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - User settings
	/// A notification posted after the value of `requireAuthentication` in `KDefaults` has changed.
	static var KSAuthenticationRequireTimeoutValueDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - Theme settings
	/// A notification posted after the value of selected theme has changed.
	static var ThemeUpdateNotification: NSNotification.Name {
		return Notification.Name(#function)
	}

	/// A notification posted after the value of `darkThemeOption` in `UserSettings` has changed.
	static var KSAutomaticDarkThemeDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
}
