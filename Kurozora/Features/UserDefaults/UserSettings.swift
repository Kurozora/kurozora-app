//
//  UserSettings.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class UserSettings: UserDefaults {
	/// The base UserDefaults suit of the Kurozora Apps.
	static var shared: UserDefaults {
        let combined = UserDefaults.standard
        combined.addSuite(named: "group.settings.app.kurozora.anime")
        return combined
    }

	/// Set value for key in shared KDefaults.
	static func set(_ value: Any?, forKey key: UserSettingsKey) {
		shared.set(value, forKey: key.rawValue)
	}
}

// MARK: - Settings
extension UserSettings {
	/// Return the array of collapsed sections in settings.
	static var collapsedSections: [Int] {
		guard let collapsedSections = shared.array(forKey: "collapsedSections") as? [Int] else { return [3] }

		return collapsedSections
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

	/// Returns an array of library sort types with the user's preferred sort type for each section.
//	static var librarySortTypes: [String: [Int: Int]] {
//		guard let librarySortTypes = shared.dictionary(forKey: #function) as? [String: [Int: Int]] else { return [:] }
//		return librarySortTypes
//	}
}

// MARK: - Forums
extension UserSettings {
	/// Returns an integer indicating the forum page the user was on last.
	static var forumsPage: Int {
		return shared.integer(forKey: #function)
	}
}

// MARK: - Notification settings
extension UserSettings {
	/// Returns a boolean indicating if notifications are allowed.
	static var notificationsAllowed: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns an integer indicating the notifications persistency type.
	static var notificationsPersistent: Int {
		return shared.integer(forKey: #function)
	}

	/// Returns an integer indicating the notifications grouping type.
	static var notificationsGrouping: Int {
		return shared.integer(forKey: #function)
	}

	/// Returns a boolean indicating if notifications sound is allowed.
	static var notificationsSound: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if notifications vibration is allowed.
	static var notificationsVibration: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns a boolean indicating if notifications badge is allowed.
	static var notificationsBadge: Bool {
		return shared.bool(forKey: #function)
	}

	/// Returns an integer indicating the notifications alert trype.
	static var alertType: Int {
		return shared.integer(forKey: #function)
	}
}

// MARK: - App customization
extension UserSettings {
	/// Returns a string indicating the currently used theme.
	static var currentTheme: String? {
		guard let currentTheme = shared.string(forKey: #function) else { return "" }
		return currentTheme
	}

	/// Returns a string indicating the currently used app icon.
	static var appIcon: String {
		let primaryIcon = "AppIcon60x60"
		guard let appIcon = shared.string(forKey: #function) else { return primaryIcon }
		return (UIImage(named: appIcon) != nil) ? appIcon : primaryIcon
	}

	/// Returns an integer indicating the default browser.
	static var defaultBrowser: Int {
		return shared.integer(forKey: #function)
	}
}
