//
//  UserSettings.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class UserSettings: UserDefaults {
	/// The base UserDefaults suit of the Kurozora apps.
	static var shared: UserDefaults {
        let combined = UserDefaults.standard
        combined.addSuite(named: "group.settings.app.kurozora.anime")
        return combined
    }

	/// Set value for key in shared UserDefaults.
	static func set(_ value: Any?, forKey key: UserSettingsKey) {
		shared.set(value, forKey: key.rawValue)
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

// MARK: - App customization
extension UserSettings {
	/// Returns a string indicating the currently used theme.
	static var currentTheme: String {
		guard let currentTheme = shared.string(forKey: #function) else { return "" }
		return currentTheme
	}

	/// Returns a string indicating the currently used app icon.
	static var appIcon: String {
		let primaryIcon = "AppIcon60x60"
		guard let appIcon = shared.string(forKey: #function) else { return primaryIcon }
		return (UIImage(named: appIcon) != nil) ? appIcon : primaryIcon
	}

	/// Returns a `KBrowser` type indicating the preferred default browser.
	static var defaultBrowser: KBrowser {
		guard let defaultBrowser = KBrowser(rawValue: shared.integer(forKey: #function)) else { return .kurozora }
		return defaultBrowser
	}
}

// MARK: - Appearence settings
extension UserSettings {
	/// Returns a boolean indicating if automatic dark theme is on.
	static var appearanceOption: Int {
		return shared.integer(forKey: #function)
	}

	/// Returns a boolean indicating if automatic dark theme is on.
	static var automaticDarkTheme: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns a string indicating the preferred dark theme option. Default value is 2, neither automatic nor scheduled.
	static var darkThemeOption: Int {
		return shared.integer(forKey: #function)
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
		return shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if large titles is on.
	static var largeTitlesEnabled: Bool {
		return shared.bool(forKey: #function)
	}
}

// MARK: - Authentication
extension UserSettings {
	/// Returns a boolean indicating whether authentication is enabled.
	static var authenticationEnabled: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns an `AuthenticationInterval` type indicating the preferred authentication interval.
	static var authenticationInterval: AuthenticationInterval {
		guard let authenticationInterval = AuthenticationInterval(rawValue: shared.integer(forKey: #function)) else { return .immediately }
		return authenticationInterval
	}
}

// MARK: - Forums
extension UserSettings {
	/// Returns an integer indicating the forum page the user was on last.
	static var forumsPage: Int {
		return shared.integer(forKey: #function)
	}
}

// MARK: - Library
extension UserSettings {
	/// Returns an integer indicating the library page the user was on last.
	static var libraryPage: Int {
		return shared.integer(forKey: #function)
	}

	/// Returns an array of library sections with the user's preferred cell style for each section.
	static var libraryCellStyles: [String: Int] {
		guard let libraryLayouts = shared.dictionary(forKey: #function) as? [String: Int] else { return [:] }
		return libraryLayouts
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
		return shared.bool(forKey: #function)
	}

	/// Returns an integer indicating the notifications grouping type.
	static var notificationsGrouping: Int {
		return shared.integer(forKey: #function)
	}

	/// Returns a boolean indicating if notifications sound is allowed.
	static var notificationsSound: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if notifications badge is allowed.
	static var notificationsBadge: Bool {
		return shared.bool(forKey: #function)
	}
}
