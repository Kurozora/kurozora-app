//
//  UserSettingsKey.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/// Notificartions key used to get notifications settings
enum UserSettingsKey: String {
	// Settings keys
	case collapsedSections

	// Library keys
	case libraryPage
	case libraryLayouts

	// Forums keys
	case forumsPage

	// Notification settings keys
	case notificationsAllowed
	case notificationsGrouping
	case notificationsPersistent
	case notificationsSound
	case notificationsVibration
	case notificationsBadge
	case alertType

	// Appearence settings keys
	case appearanceOption
	case automaticDarkTheme
	case darkThemeOption
	case darkThemeOptionStart
	case darkThemeOptionEnd
	case trueBlackEnabled
	case largeTitlesEnabled

	// App customization keys
	case currentTheme
	case appIcon
	case defaultBrowser
}
