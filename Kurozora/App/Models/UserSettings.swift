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
	/// The base `UserDefaults` suit of the Kurozora apps.
	static var shared: UserDefaults {
		let combined = UserDefaults.standard
		combined.addSuite(named: "group.settings.app.kurozora.anime")
		combined.register(defaults: [
			UserSettingsKey.notificationsAllowed.rawValue: true,
			UserSettingsKey.notificationsSound.rawValue: true,
			UserSettingsKey.notificationsBadge.rawValue: true,
			UserSettingsKey.startupSoundAllowed.rawValue: true,
			UserSettingsKey.uiSoundsAllowed.rawValue: true,
			UserSettingsKey.hapticsAllowed.rawValue: true,
			UserSettingsKey.confettiLastSeenAt.rawValue: Date.distantPast,
			UserSettingsKey.currentSplashScreenAnimation.rawValue: SplashScreenAnimation.default.rawValue,
			UserSettingsKey.isReduceMotionEnabled.rawValue: UIAccessibility.isReduceMotionEnabled,
			UserSettingsKey.isReduceMotionSyncEnabled.rawValue: true,
		])
		return combined
	}

	/// Set value for key in shared `UserDefaults`.
	static func set(_ value: Any?, forKey key: UserSettingsKey) {
		self.shared.set(value, forKey: key.rawValue)
	}
}

// MARK: - Account
extension UserSettings {
	/// Returns a string of the currently selected account
	static var selectedAccount: String {
		guard let selectedAccount = shared.string(forKey: #function) else { return "" }
		return selectedAccount
	}
}

// MARK: - API
extension UserSettings {
	/// Returns a `KurozoraAPI` type indicating the preferred API endpoint.
	static var apiEndpoint: KurozoraAPI? {
		#if DEBUG
		guard let baseURL = shared.string(forKey: #function) else { return nil }
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
		guard let currentAnimation = SplashScreenAnimation(rawValue: shared.integer(forKey: #function)) else { return .default }
		return currentAnimation
	}

	/// Returns a string indicating the currently used theme.
	static var currentTheme: String {
		guard let currentTheme = shared.string(forKey: #function) else { return "" }
		return currentTheme
	}

	/// Returns a string indicating the currently used theme's name.
	static var currentThemeName: String {
		guard let currentThemeName = shared.string(forKey: #function) else { return "" }
		return currentThemeName
	}

	/// Returns a string indicating the currently used app icon.
	static var appIcon: String {
		let primaryIcon = "Kurozora"
		guard var appIcon = shared.string(forKey: #function) else { return primaryIcon }

		if #available(iOS 18.0, *) {
			appIcon += " Preview"
		}

		return UIImage(named: appIcon) != nil ? appIcon : primaryIcon
	}

	/// Returns a `KBrowser` type indicating the preferred default browser.
	static var defaultBrowser: KBrowser {
		guard let defaultBrowser = KBrowser(rawValue: shared.integer(forKey: #function)) else { return .kurozora }
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

// MARK: - Library
extension UserSettings {
	/// Returns an integer indicating the library page the user was on last.
	static var libraryPage: Int {
		return self.shared.integer(forKey: #function)
	}

	/// Returns an array of library sections with the user's preferred cell style for each section.
	static var libraryCellStyles: [String: Int] {
		guard let libraryLayouts = shared.dictionary(forKey: #function) as? [String: Int] else { return [:] }
		return libraryLayouts
	}

	/// Returns a library kind indicating the library kind the user was on last.
	static var libraryKind: KKLibrary.Kind {
		guard let libraryKind = KKLibrary.Kind(rawValue: shared.integer(forKey: #function)) else { return .shows }
		return libraryKind
	}

	/// Returns the default library sort types for each library kind and status.
	static var librarySortTypes: [KKLibrary.Kind: [KKLibrary.Status: (sortType: KKLibrary.SortType, sortOption: KKLibrary.SortType.Option)]] {
		let decoder = PropertyListDecoder()

		guard
			let data = shared.data(forKey: #function),
			let rawLibrarySortTypes = try? decoder.decode([Int: [Int: Int]].self, from: data)
		else {
			return [:]
		}

		var librarySortTypes: [KKLibrary.Kind: [KKLibrary.Status: (KKLibrary.SortType, KKLibrary.SortType.Option)]] = [:]

		for (kindRaw, statusMap) in rawLibrarySortTypes {
			guard let kind = KKLibrary.Kind(rawValue: kindRaw) else { continue }

			var statusDict: [KKLibrary.Status: (KKLibrary.SortType, KKLibrary.SortType.Option)] = [:]

			for (statusRaw, encodedValue) in statusMap {
				guard let status = KKLibrary.Status(rawValue: statusRaw) else { continue }

				let sortTypeRaw = encodedValue >> 8
				let optionRaw = encodedValue & 0xFF

				guard
					let sortType = KKLibrary.SortType(rawValue: sortTypeRaw),
					let option = KKLibrary.SortType.Option(rawValue: optionRaw)
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

// MARK: - Sounds & Haptics Settings
extension UserSettings {
	/// Returns a string indicating the preferred chime sound.
	static var selectedChime: String {
		guard let selectedChime = shared.string(forKey: #function) else { return "" }
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
