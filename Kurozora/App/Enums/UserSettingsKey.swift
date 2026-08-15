//
//  UserSettingsKey.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/// The set of available user settings keys.
enum UserSettingsKey: String, CaseIterable {
	// Account keys
	/// The key to the selected account.
	case selectedAccount
	/// The key indicating whether account storage migration has completed.
	case accountStorageMigrationCompleted
	/// The key to the style used to rate and review media.
	case ratingStyle

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
	/// The key to the selected theme's name.
	case currentThemeName
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

	// Gestures settings keys
	/// The key indicating whether swiping in from the trailing screen edge reopens the previous screen.
	case forwardNavigationEnabled

	// Library keys
	/// The key to the last selected library page.
	case libraryPage
	/// The key to the last selected library cell style.
	case libraryCellStyles
	/// The key to the last selected library kind.
	case libraryKind
	/// The key to the default library sort types.
	case librarySortTypes
	/// The key to the user's column preferences for the table layout.
	case libraryColumnPreferences
	/// The key to the user's compact-layout title visibility preferences.
	case libraryCompactTitleVisibilities

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
	/// The key to the last notification registration request time.
	case lastNotificationRegistrationRequest

	// Face Detection
	/// The key to the detection results that have already been submitted.
	case faceDetectionSubmitted

	// Lyrics capture (DEBUG)
	/// The key to the privileged Apple Music developer token used for lyrics capture.
	case appleMusicPrivilegedToken

	// Lyrics keys
	/// The key indicating whether the lyrics transliteration is shown.
	case lyricsShowsTransliteration
	/// The key to the selected lyrics translation language.
	case lyricsTranslationLanguage
	/// The key to the text shown larger when a line and its pronunciation both appear.
	case lyricsLargerText
	/// The key to the font size of the text shown in the floating lyrics window.
	case lyricsFloatingWindowFontSize
	/// The key to the number of lyric lines shown in the floating lyrics window.
	case lyricsFloatingWindowRows
	/// The key indicating whether the floating lyrics window shows a translation.
	case lyricsFloatingWindowShowsTranslation
	/// The key indicating whether the floating lyrics window opens automatically when leaving the app.
	case lyricsFloatingWindowAutoOpen

	// Translation keys
	/// The key to the language user-generated content is translated into.
	case translationLanguage
	/// The key to the languages the user does not want translated automatically.
	case autoTranslateExcludedLanguages

	// Music keys
	/// The key indicating whether the now-playing accessory shows total time instead of remaining time.
	case musicAccessoryShowsTotalTime
	/// The key indicating whether songs crossfade into one another.
	case musicCrossfadeEnabled
	/// The key to the crossfade duration in seconds.
	case musicCrossfadeDuration
	/// The key to the number of seconds a skip button seeks while held.
	case musicSkipDuration
	/// The key indicating whether a notification is posted when the song changes.
	case musicSongChangeNotificationsEnabled

	// MiniPlayer keys
	/// The key to the conditions under which the MiniPlayer reveals its metadata and controls.
	case miniPlayerChromeVisibility
	/// The key indicating whether the MiniPlayer reveals its metadata briefly when the song changes.
	case miniPlayerRevealsOnSongChange
	/// The key indicating whether the MiniPlayer floats above the windows of other apps.
	case miniPlayerStaysOnTop
	/// The key indicating whether the MiniPlayer appears on every Space.
	case miniPlayerShowsOnAllSpaces
	/// The key indicating whether the MiniPlayer is showing.
	case miniPlayerIsShowing
	/// The key to the height the MiniPlayer's lyrics pane opens to.
	case miniPlayerLyricsPaneHeight
}
