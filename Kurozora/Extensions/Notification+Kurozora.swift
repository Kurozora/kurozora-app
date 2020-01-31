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
	static var KFavoriteShowsListDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - User state
	static var KUserIsSignedInDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - Notification settings
	static var KSNotificationsBadgeIsOn: NSNotification.Name {
		return Notification.Name(#function)
	}
	static var KSNotificationOptionsValueLabelsNotification: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - App settings
	static var KSAppAppearanceDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
	static var KSAppIconDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - User settings
	static var KSAuthenticationRequireTimeoutValueDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}

	// MARK: - Theme settings
	static var ThemeUpdateNotification: NSNotification.Name {
		return Notification.Name(#function)
	}
	static var KSAutomaticDarkThemeDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
}
