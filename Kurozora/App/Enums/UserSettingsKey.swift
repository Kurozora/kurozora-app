//
//  UserSettingsKey.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/// The set of available user settings keys.
enum UserSettingsKey: String {
	// Account keys
	/// The key to the selected account.
	case selectedAccount

	// App customization keys
	/// The key to the selected theme.
	case currentTheme
	/// The key to the selected app icon.
	case appIcon
	/// The key to the selected browser.
	case defaultBrowser
	/// The key indicating the app was launched once.
	case launchedOnce

	// Appearence settings keys
	/// The key to the selected appearance option.
	case appearanceOption
	/// The key to the automatic dark theme option.
	case automaticDarkTheme
	/// The key to the selected dark theme option.
	case darkThemeOption
	/// The key to the selected dark theme start time.
	case darkThemeOptionStart
	/// The key to the selected dark theme option end time.
	case darkThemeOptionEnd
	/// The key to the selected true black settings.
	case trueBlackEnabled
	/// The key to the selected large title enabled settings.
	case largeTitlesEnabled

	// Authentication
	/// The key to the authentication enabled option.
	case authenticationEnabled
	/// The key to the authentication interval option.
	case authenticationInterval

	// Forums keys
	/// The key to the last selected forums page.
	case forumsPage

	// Library keys
	/// The key to the last selected library page.
	case libraryPage
	/// The key to the last selected library cell style.
	case libraryCellStyles

	// Notification settings keys
	/// The key to the selected option for allowing notifications.
	case notificationsAllowed
	/// The key to the selected notification grouping option.
	case notificationsGrouping
	/// The key to the selected notification sound option.
	case notificationsSound
	/// The key to the selcted notification badge option.
	case notificationsBadge

	// Register for notification
	/// The key to the last notifcation registration reuest time.
	case lastNotificationRegistrationRequest
}
