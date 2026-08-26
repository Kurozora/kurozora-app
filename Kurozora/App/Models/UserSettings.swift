//
//  UserSettings.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class UserSettings: UserDefaults {
	/// The App Group suite name shared between the main app and extensions.
	static let suiteName = "group.settings.app.kurozora.tracker"

	/// The canonical name of the primary app icon.
	static let defaultAppIcon = "Kurozora"

	/// The base `UserDefaults` suite of the Kurozora apps, backed by the shared App Group container.
	static var shared: UserDefaults {
		let shared = UserDefaults(suiteName: suiteName) ?? .standard
		shared.register(defaults: [
			UserSettingsKey.notificationsAllowed.rawValue: true,
			UserSettingsKey.notificationsSound.rawValue: true,
			UserSettingsKey.notificationsBadge.rawValue: true,
			UserSettingsKey.notificationsMirrorWatch.rawValue: true,
			UserSettingsKey.startupSoundAllowed.rawValue: true,
			UserSettingsKey.uiSoundsAllowed.rawValue: true,
			UserSettingsKey.hapticsAllowed.rawValue: true,
			UserSettingsKey.confettiLastSeenAt.rawValue: Date.distantPast,
			UserSettingsKey.currentSplashScreenAnimation.rawValue: SplashScreenAnimation.default.rawValue,
			UserSettingsKey.isReduceMotionEnabled.rawValue: UIAccessibility.isReduceMotionEnabled,
			UserSettingsKey.isReduceMotionSyncEnabled.rawValue: true,
			UserSettingsKey.forwardNavigationEnabled.rawValue: true,
			UserSettingsKey.musicCrossfadeDuration.rawValue: CrossfadeDuration.default.rawValue,
			UserSettingsKey.musicSkipDuration.rawValue: SkipDuration.default.rawValue,
			UserSettingsKey.videoAutoplayPolicy.rawValue: VideoAutoplayPolicy.default.rawValue,
			UserSettingsKey.wifiVideoQuality.rawValue: VideoQuality.defaultWiFi.rawValue,
			UserSettingsKey.cellularVideoQuality.rawValue: VideoQuality.defaultCellular.rawValue,
			UserSettingsKey.liveTextAnalyzerEnabled.rawValue: true,
			UserSettingsKey.lyricsFloatingWindowAutoOpen.rawValue: true,
			UserSettingsKey.miniPlayerStaysOnTop.rawValue: true,
			UserSettingsKey.miniPlayerShowsOnAllSpaces.rawValue: true,
			UserSettingsKey.ratingStyle.rawValue: RatingStyle.standard.rawValue,
		])
		return shared
	}

	/// Set value for key in shared `UserDefaults`.
	static func set(_ value: Any?, forKey key: UserSettingsKey) {
		self.shared.set(value, forKey: key.rawValue)
	}

	/// One-time migration of existing settings from `.standard` to the shared App Group suite.
	static func migrateToSharedSuiteIfNeeded() {
		let shared = UserDefaults(suiteName: suiteName) ?? .standard
		guard !shared.bool(forKey: "sharedSuiteMigrationCompleted") else { return }

		let standard = UserDefaults.standard
		for key in UserSettingsKey.allCases {
			if let value = standard.object(forKey: key.rawValue) {
				shared.set(value, forKey: key.rawValue)
			}
		}
		shared.set(true, forKey: "sharedSuiteMigrationCompleted")
	}
}

// MARK: - Account
extension UserSettings {
	/// Returns a string of the currently selected account
	static var selectedAccount: String {
		guard let selectedAccount = self.shared.string(forKey: #function) else { return "" }
		return selectedAccount
	}

	/// Returns a boolean indicating whether account storage migration has completed.
	static var accountStorageMigrationCompleted: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns the style used to rate and review media.
	static var ratingStyle: RatingStyle {
		guard let ratingStyle = RatingStyle(rawValue: self.shared.integer(forKey: #function)) else { return .standard }
		return ratingStyle
	}
}

// MARK: - API
extension UserSettings {
	/// Returns a `KurozoraAPI` type indicating the preferred API endpoint.
	static var apiEndpoint: KurozoraAPI? {
		#if DEBUG
		guard let baseURL = self.shared.string(forKey: #function) else { return nil }
		return KurozoraAPI.allCases.first { apiEndpoint in
			apiEndpoint.baseURL == baseURL
		} ?? .custom(baseURL)
		#else
		return nil
		#endif
	}
}

// MARK: - App
extension UserSettings {
	/// Returns the number of times the app has been launched.
	static var sessionActionsCount: Int {
		return self.shared.integer(forKey: #function)
	}
}

// MARK: - App customization
extension UserSettings {
	/// Returns a string indicating the currently used splash screen animation.
	static var currentSplashScreenAnimation: SplashScreenAnimation {
		guard let currentAnimation = SplashScreenAnimation(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return currentAnimation
	}

	/// Returns a string indicating the currently used theme.
	static var currentTheme: String {
		guard let currentTheme = self.shared.string(forKey: #function) else { return "" }
		return currentTheme
	}

	/// Returns a string indicating the currently used theme's name.
	static var currentThemeName: String {
		guard let currentThemeName = self.shared.string(forKey: #function) else { return "" }
		return currentThemeName
	}

	/// Returns the name of the currently used app icon, as listed in `App Icons.plist`.
	static var appIcon: String {
		guard let appIcon = self.shared.string(forKey: #function), appIcon != self.defaultAppIcon else {
			return self.defaultAppIcon
		}

		return UIImage(named: "\(appIcon) Preview") != nil ? appIcon : self.defaultAppIcon
	}

	/// Returns a `KBrowser` type indicating the preferred default browser.
	static var defaultBrowser: KBrowser {
		guard let defaultBrowser = KBrowser(rawValue: self.shared.integer(forKey: #function)) else { return .kurozora }
		return defaultBrowser
	}

	/// Returns a boolean indicating if the app has been launched once.
	static var launchedOnce: Bool {
		return self.shared.bool(forKey: #function)
	}
}

// MARK: - App Review
extension UserSettings {
	/// Returns a boolean indicating if the user has been asked for a review.
	static var lastReviewRequestDate: Date {
		return self.shared.object(forKey: #function) as? Date ?? .distantPast
	}

	/// Returns an integer indicating the number of times the user has been asked for a review.
	static var reviewRequestCount: Int {
		return self.shared.integer(forKey: #function)
	}
}

// MARK: - Appearance settings
extension UserSettings {
	/// Returns a boolean indicating if automatic dark theme is on.
	static var appearanceOption: Int {
		return self.shared.integer(forKey: #function)
	}

	/// Returns a boolean indicating if automatic dark theme is on.
	static var automaticDarkTheme: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a string indicating the preferred dark theme option. Default value is 2, neither automatic nor scheduled.
	static var darkThemeOption: Int {
		return self.shared.integer(forKey: #function)
	}

	/// Returns a string indicating the preferred custom dark theme start time.
	static var darkThemeOptionStart: Date {
		guard let darkThemeOptionStart = shared.date(forKey: #function) else { return Date() }
		return darkThemeOptionStart
	}

	/// Returns a string indicating the preferred custom dark theme end time.
	static var darkThemeOptionEnd: Date {
		guard let darkThemeOptionEnd = shared.date(forKey: #function) else {
			guard let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) else { return Date() }
			return nextHour
		}
		return darkThemeOptionEnd
	}

	/// Returns a boolean indicating if true black theme is on.
	static var trueBlackEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if large titles is on.
	static var largeTitlesEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}
}

// MARK: - Authentication
extension UserSettings {
	/// Returns a boolean indicating whether authentication is enabled.
	static var authenticationEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns an `AuthenticationInterval` type indicating the preferred authentication interval.
	static var authenticationInterval: AuthenticationInterval {
		guard let authenticationInterval = AuthenticationInterval(rawValue: shared.integer(forKey: #function)) else { return .immediately }
		return authenticationInterval
	}
}

// MARK: - Confetti
extension UserSettings {
	/// Returns a boolean indicating when the confetti was last seen at.
	static var confettiLastSeenAt: Date {
		guard let confettiLastSeenAt = shared.object(forKey: #function) as? Date else { return Date.distantPast }
		return confettiLastSeenAt
	}
}

// MARK: - Forums
extension UserSettings {
	/// Returns an integer indicating the forum page the user was on last.
	static var forumsPage: Int {
		return self.shared.integer(forKey: #function)
	}
}

// MARK: - Gestures
extension UserSettings {
	/// Returns a boolean indicating whether swiping in from the trailing screen edge reopens the previous screen.
	static var forwardNavigationEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}
}

// MARK: - Library
extension UserSettings {
	/// Returns an integer indicating the library page the user was on last.
	static var libraryPage: Int {
		return self.shared.integer(forKey: #function)
	}

	/// Returns the stored map of the user's preferred cell style for each library kind and status.
	static var libraryCellStyles: [String: Int] {
		guard let libraryLayouts = shared.dictionary(forKey: #function) as? [String: Int] else { return [:] }
		return libraryLayouts
	}

	/// Returns a library kind indicating the library kind the user was on last.
	static var libraryKind: LibraryKind {
		guard let libraryKind = LibraryKind(rawValue: shared.integer(forKey: #function)) else { return .shows }
		return libraryKind
	}

	/// Returns the default library sort types for each library kind and status.
	static var librarySortTypes: [LibraryKind: [LibraryStatus: (sortType: LibrarySortType, sortOption: LibrarySortOption)]] {
		let decoder = PropertyListDecoder()

		guard
			let data = shared.data(forKey: #function),
			let rawLibrarySortTypes = try? decoder.decode([Int: [Int: Int]].self, from: data)
		else {
			return [:]
		}

		var librarySortTypes: [LibraryKind: [LibraryStatus: (LibrarySortType, LibrarySortOption)]] = [:]

		for (kindRaw, statusMap) in rawLibrarySortTypes {
			guard let kind = LibraryKind(rawValue: kindRaw) else { continue }

			var statusDict: [LibraryStatus: (LibrarySortType, LibrarySortOption)] = [:]

			for (statusRaw, encodedValue) in statusMap {
				guard let status = LibraryStatus(rawValue: statusRaw) else { continue }

				let sortTypeRaw = encodedValue >> 8
				let optionRaw = encodedValue & 0xFF

				guard
					let sortType = LibrarySortType(rawValue: sortTypeRaw),
					let option = LibrarySortOption(rawValue: optionRaw)
				else { continue }

				statusDict[status] = (sortType, option)
			}

			librarySortTypes[kind] = statusDict
		}

		return librarySortTypes
	}
}

// MARK: - Notification registration
extension UserSettings {
	/// Returns a string indicating the currently used theme.
	static var lastNotificationRegistrationRequest: Date? {
		guard let lastNotificationRegistrationRequest = shared.date(forKey: #function) else { return nil }
		return lastNotificationRegistrationRequest
	}
}

// MARK: - Notification settings
extension UserSettings {
	/// Returns a boolean indicating if notifications are allowed.
	static var notificationsAllowed: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns an integer indicating the notifications grouping type.
	static var notificationsGrouping: Int {
		return self.shared.integer(forKey: #function)
	}

	/// Returns a boolean indicating if notifications sound is allowed.
	static var notificationsSound: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if notifications badge is allowed.
	static var notificationsBadge: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if the Watch should mirror the iPhone's notification grouping.
	static var notificationsMirrorWatch: Bool {
		return self.shared.bool(forKey: #function)
	}
}

// MARK: - Motion Settings
extension UserSettings {
	/// Returns a boolean indicating if reduce motion is enabled.
	static var isReduceMotionEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if reduce motion's "Sync with Device Settings" is enabled.
	static var isReduceMotionSyncEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if Smart Rotation Lock is enabled.
	static var isSmartRotationLockEnabled: Bool {
		return false // self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if Portrait Lock Buddy is enabled.
	static var isPortraitLockBuddyEnabled: Bool {
		return true // self.shared.bool(forKey: #function)
	}
}

#if DEBUG
// MARK: - Face Detection
extension UserSettings {
	/// Returns the detection results that have already been submitted.
	static var faceDetectionSubmitted: Set<String> {
		guard let stored = self.shared.array(forKey: UserSettingsKey.faceDetectionSubmitted.rawValue) as? [String] else { return [] }
		return Set(stored)
	}
}

// MARK: - Lyrics Capture
extension UserSettings {
	/// Returns the privileged Apple Music developer token used for lyrics capture.
	static var appleMusicPrivilegedToken: String {
		guard let token = self.shared.string(forKey: #function) else { return "" }
		return token
	}
}
#endif

// MARK: - Lyrics
extension UserSettings {
	/// Returns a Boolean indicating whether the lyrics transliteration is shown.
	static var lyricsShowsTransliteration: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns the selected lyrics translation language.
	static var lyricsTranslationLanguage: String? {
		return self.shared.string(forKey: #function)
	}

	/// Returns the text shown larger when a line and its pronunciation both appear.
	static var lyricsLargerText: LyricsLargerText {
		guard let largerText = LyricsLargerText(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return largerText
	}

	/// Returns the font size of the text shown in the floating lyrics window.
	static var lyricsFloatingWindowFontSize: LyricsFloatingWindowFontSize {
		guard let fontSize = LyricsFloatingWindowFontSize(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return fontSize
	}

	/// Returns the number of lyric lines shown in the floating lyrics window.
	static var lyricsFloatingWindowRows: LyricsFloatingWindowRows {
		guard let rows = LyricsFloatingWindowRows(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return rows
	}

	/// Returns a Boolean indicating whether the floating lyrics window shows a translation.
	static var lyricsFloatingWindowShowsTranslation: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether the floating lyrics window opens automatically when leaving the app.
	static var lyricsFloatingWindowAutoOpen: Bool {
		return self.shared.bool(forKey: #function)
	}
}

// MARK: - Translation
extension UserSettings {
	/// Returns the language identifier user-generated content is translated into.
	static var translationLanguage: String? {
		return self.shared.string(forKey: #function)
	}

	/// Returns the language identifiers the user does not want translated automatically.
	///
	/// Automatic translation is on by default, so this stores only the exceptions.
	static var autoTranslateExcludedLanguages: [String] {
		return self.shared.stringArray(forKey: #function) ?? []
	}
}

// MARK: - Music
extension UserSettings {
	/// Returns a Boolean indicating whether the now-playing accessory shows total time instead of remaining time.
	static var musicAccessoryShowsTotalTime: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether songs crossfade into one another.
	static var musicCrossfadeEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns the crossfade duration.
	static var musicCrossfadeDuration: CrossfadeDuration {
		guard let duration = CrossfadeDuration(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return duration
	}

	/// Returns the skip duration.
	static var musicSkipDuration: SkipDuration {
		guard let duration = SkipDuration(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return duration
	}

	/// Returns the conditions under which trailers play automatically.
	static var videoAutoplayPolicy: VideoAutoplayPolicy {
		guard let policy = VideoAutoplayPolicy(rawValue: self.shared.integer(forKey: #function)) else { return .default }
		return policy
	}

	/// Returns the quality trailers are held at on Wi-Fi.
	static var wifiVideoQuality: VideoQuality {
		guard let quality = VideoQuality(rawValue: self.shared.integer(forKey: #function)) else { return .defaultWiFi }
		return quality
	}

	/// Returns the quality trailers are held at on cellular.
	static var cellularVideoQuality: VideoQuality {
		guard let quality = VideoQuality(rawValue: self.shared.integer(forKey: #function)) else { return .defaultCellular }
		return quality
	}

	/// Returns the place saved images are written to.
	static var mediaSaveDestination: Int {
		return self.shared.integer(forKey: #function)
	}

	/// Returns the bookmark of the folder saved images are written to.
	static var mediaSaveDirectoryBookmark: Data? {
		return self.shared.data(forKey: #function)
	}

	/// Returns a Boolean indicating whether saved images are also added to an album named Kurozora.
	static var mediaSaveToKurozoraAlbum: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether text and subjects inside media are recognized.
	static var liveTextAnalyzerEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether a notification is posted when the song changes.
	static var musicSongChangeNotificationsEnabled: Bool {
		return self.shared.bool(forKey: #function)
	}
}

// MARK: - MiniPlayer
extension UserSettings {
	/// Returns a Boolean indicating whether the MiniPlayer reveals its metadata briefly when the song changes.
	static var miniPlayerRevealsOnSongChange: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether the MiniPlayer floats above the windows of other apps.
	static var miniPlayerStaysOnTop: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether the MiniPlayer appears on every Space.
	static var miniPlayerShowsOnAllSpaces: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a Boolean indicating whether the MiniPlayer is showing.
	static var miniPlayerIsShowing: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns the height the MiniPlayer's lyrics pane opens to.
	static var miniPlayerLyricsPaneHeight: Int {
		return self.shared.integer(forKey: #function)
	}
}

// MARK: - Sounds & Haptics Settings
extension UserSettings {
	/// Returns a string indicating the preferred chime sound.
	static var selectedChime: String {
		guard let selectedChime = shared.string(forKey: #function) else { return "Default" }
		return selectedChime
	}

	/// Returns a boolean indicating if startup sound is enabled.
	static var startupSoundAllowed: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if UI sounds are enabled.
	static var uiSoundsAllowed: Bool {
		return self.shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if haptics are enabled.
	static var hapticsAllowed: Bool {
		return self.shared.bool(forKey: #function)
	}
}
