//
//  UserSettings.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

class UserSettings: NSObject {
	/// Notificartions key used to get notifications settings
	enum UserSettingsKey: String {
		// Settings keys
		case collapsedSections = "collapsedSections"

		// Library keys
		case libraryPage = "libraryPage"
		case libraryLayouts = "libraryLayouts"

		// Forums keys
		case forumsPage = "forumsPage"

		// Notification settings keys
		case notificationsAllowed = "notificationsAllowed"
		case notificationsGrouping = "notificationsGrouping"
		case notificationsPersistent = "notificationsPersistent"
		case notificationsSound = "notificationsSound"
		case notificationsVibration = "notificationsVibration"
		case notificationsBadge = "notificationsBadge"
		case alertType = "alertType"

		// Appearence settings keys
		case appearanceOption = "appearanceOption"
		case automaticDarkTheme = "automaticDarkTheme"
		case darkThemeOption = "darkThemeOption"
		case darkThemeOptionStart = "darkThemeOptionStart"
		case darkThemeOptionEnd = "darkThemeOptionEnd"
		case trueBlackEnabled = "trueBlackEnabled"
		case largeTitlesEnabled = "largeTitlesEnabled"

		// App customization keys
		case currentTheme = "currentTheme"
		case appIcon = "appIcon"
	}

	/// Set value for key in shared KDefaults
	static func set(_ value: Any?, forKey key: UserSettingsKey) {
		GlobalVariables().KUserDefaults?.set(value, forKey: key.rawValue)
	}
}

// MARK: - Settings
extension UserSettings {
	/// Return the array of collapsed sections in settings
	static var collapsedSections: [Int] {
		guard let collapsedSections = GlobalVariables().KUserDefaults?.array(forKey: "collapsedSections") as? [Int] else { return [3] }
		return collapsedSections
	}
}

// MARK: - Appearence settings
extension UserSettings {
	/// Returns a boolean indicating if automatic dark theme is on
	static var appearanceOption: Int {
		guard let appearanceOption = GlobalVariables().KUserDefaults?.integer(forKey: "appearanceOption") else { return 0 }
		return appearanceOption
	}

	/// Returns a boolean indicating if automatic dark theme is on
	static var automaticDarkTheme: Bool {
		guard let automaticDarkTheme = GlobalVariables().KUserDefaults?.bool(forKey: "automaticDarkTheme") else { return false }
		return automaticDarkTheme
	}

	/// Returns a string indicating the preferred dark theme option.
	/// Default value is 2, neither automatic nor scheduled.
	static var darkThemeOption: Int {
		guard let darkThemeOption = GlobalVariables().KUserDefaults?.integer(forKey: "darkThemeOption") else { return 2 }
		return darkThemeOption
	}

	/// Returns a string indicating the preferred custom dark theme start time
	static var darkThemeOptionStart: Date {
		guard let darkThemeOptionStart = GlobalVariables().KUserDefaults?.date(forKey: "darkThemeOptionStart") else { return Date() }
		return darkThemeOptionStart
	}

	/// Returns a string indicating the preferred custom dark theme end time
	static var darkThemeOptionEnd: Date {
		guard let darkThemeOptionEnd = GlobalVariables().KUserDefaults?.date(forKey: "darkThemeOptionEnd") else {
			guard let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) else { return Date() }
			return nextHour
		}
		return darkThemeOptionEnd
	}

	/// Returns a boolean indicating if true black theme is on
	static var trueBlackEnabled: Bool {
		guard let trueBlackEnabled = GlobalVariables().KUserDefaults?.bool(forKey: "trueBlackEnabled") else { return false }
		return trueBlackEnabled
	}

	/// Returns a boolean indicating if large titles is on
	static var largeTitlesEnabled: Bool {
		guard let largeTitles = GlobalVariables().KUserDefaults?.bool(forKey: "largeTitlesEnabled") else { return true }
		return largeTitles
	}
}

// MARK: - Library
extension UserSettings {
	/// Returns an integer indication the library page the user was on last
	static var libraryPage: Int {
		guard let libraryPage = GlobalVariables().KUserDefaults?.integer(forKey: "libraryPage") else { return 0 }
		return libraryPage
	}

	/// Returns an integer indication the library page the user was on last
	static var libraryLayouts: Dictionary<String, Any> {
		guard let libraryLayouts = GlobalVariables().KUserDefaults?.dictionary(forKey: "libraryLayouts") else { return [:] }
		return libraryLayouts
	}
}

// MARK: - Forums
extension UserSettings {
	/// Returns an integer indication the forum page the user was on last
	static var forumsPage: Int {
		guard let forumsPage = GlobalVariables().KUserDefaults?.integer(forKey: "forumsPage") else { return 0 }
		return forumsPage
	}
}

// MARK: - Notification settings
extension UserSettings {
	/// Returns a boolean indicating if notifications are allowed
	static var notificationsAllowed: Bool {
		guard let notificationsAllowed = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsAllowed") else { return true }
		return notificationsAllowed
	}

	/// Returns an integer indicating the notifications persistency type
	static var notificationsPersistent: Int {
		guard let notificationsPersistent = GlobalVariables().KUserDefaults?.integer(forKey: "notificationsPersistent") else { return 0 }
		return notificationsPersistent
	}

	/// Returns an integer indicating the notifications grouping type
	static var notificationsGrouping: Int {
		guard let notificationsGrouping = GlobalVariables().KUserDefaults?.integer(forKey: "notificationsGrouping") else { return 0 }
		return notificationsGrouping
	}

	/// Returns a boolean indicating if notifications sound is allowed
	static var notificationsSound: Bool {
		guard let notificationsSound = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsSound") else { return true }
		return notificationsSound
	}

	/// Returns a boolean indicating if notifications vibration is allowed
	static var notificationsVibration: Bool {
		guard let notificationsVibration = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsVibration") else { return true }
		return notificationsVibration
	}

	/// Returns a boolean indicating if notifications badge is allowed
	static var notificationsBadge: Bool {
		guard let notificationsBadge = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsBadge") else { return true }
		return notificationsBadge
	}

	/// Returns an integer indicating the notifications alert trype
	static var alertType: Int {
		guard let alertType = GlobalVariables().KUserDefaults?.integer(forKey: "alertType") else { return 0 }
		return alertType
	}
}

// MARK: - App customization
extension UserSettings {
	/// Returns a string indicating the currently used theme
	static var currentTheme: String? {
		guard let currentTheme = GlobalVariables().KUserDefaults?.string(forKey: "currentTheme") else { return "" }
		return currentTheme
	}

	/// Returns a string indicating the currently used app icon
	static var appIcon: String {
		guard let appIcon = GlobalVariables().KUserDefaults?.string(forKey: "appIcon") else { return "AppIcon60x60" }
		return appIcon
	}
}
