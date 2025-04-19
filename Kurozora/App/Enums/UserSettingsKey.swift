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

	// API keys
	/// The key to the selected API endpoint.
	case apiEndpoint

	// App
	/// The key to the number of app launches.
	case sessionActionsCount

	// App customization keys
	/// The key to the selected splash screen animation.
	case currentSplashScreenAnimation
	/// The key to the selected theme.
	case currentTheme
	/// The key to the selected app icon.
	case appIcon
	/// The key to the selected browser.
	case defaultBrowser
	/// The key indicating the app was launched once.
	case launchedOnce

	// App Review
	/// The key to the last time the app was reviewed.
	case lastReviewRequestDate
	/// The key to the app review request count.
	case reviewRequestCount

	// Appearance settings keys
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

	// Confetti
	/// The key to the last time confetti was seen at.
	case confettiLastSeenAt

	// Forums keys
	/// The key to the last selected forums page.
	case forumsPage

	// Library keys
	/// The key to the last selected library page.
	case libraryPage
	/// The key to the last selected library cell style.
	case libraryCellStyles
	/// The key to the last selected library kind.
	case libraryKind
	/// The key to the default library sort types.
	case librarySortTypes

	// Motion settings keys
	/// The key to the selected reduce motion option.
	case isReduceMotionEnabled

	/// The key to the selected sync with device settings option.
	case isReduceMotionSyncEnabled

	// Notification settings keys
	/// The key to the selected option for allowing notifications.
	case notificationsAllowed
	/// The key to the selected notification grouping option.
	case notificationsGrouping
	/// The key to the selected notification sound option.
	case notificationsSound
	/// The key to the selected notification badge option.
	case notificationsBadge

	// Sounds & Haptics settings keys
	/// The key to the selected chime option.
	case selectedChime
	/// The key to the selected option for allowing startup sound.
	case startupSoundAllowed
	/// The key to the selected option for allowing UI sounds.
	case uiSoundsAllowed
	/// The key to the selected option for allowing haptics.
	case hapticsAllowed

	// Register for notification
	/// The key to the last notification registration reuest time.
	case lastNotificationRegistrationRequest
}
