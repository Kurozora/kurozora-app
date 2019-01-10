//
//  UserSettings.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

class UserSettings: NSObject {
	/// Return the array of collapsed sections in settings
	static func collapsedSections() -> [Int] {
		guard let collapsedSections = GlobalVariables().KUserDefaults?.array(forKey: "collapsedSections") as? [Int] else { return [3] }
		return collapsedSections
	}

	/// Notificartions key used to get notifications settings
	enum UserSettingsKey: String {
		// Global notification keys
		case collapsedSections = "collapsedSections"

		// Notification keys
		case notificationsAllowed = "notificationsAllowed"
		case notificationsGrouping = "notificationsGrouping"
		case notificationsPersistent = "notificationsPersistent"
		case notificationsSound = "notificationsSound"
		case notificationsVibration = "notificationsVibration"
		case notificationsBadge = "notificationsBadge"
		case alertType = "alertType"
	}

	/// Set value for key in shared KDefaults
	static func set(_ value: Any?, forKey key: UserSettingsKey) {
		GlobalVariables().KUserDefaults?.set(value, forKey: key.rawValue)
	}

	/// Returns if notifications are allowed saved in KUserDefaults
	static func notificationsAllowed() -> Bool {
		guard let notificationsAllowed = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsAllowed") else { return true }
		return notificationsAllowed
	}


	/// Returns the notifications persistency type saved in KUserDefaults
	static func notificationsPersistent() -> Int {
		guard let notificationsPersistent = GlobalVariables().KUserDefaults?.integer(forKey: "notificationsPersistent") else { return 0 }
		return notificationsPersistent
	}

	/// Returns the notifications grouping type saved in KUserDefaults
	static func notificationsGrouping() -> Int {
		guard let notificationsGrouping = GlobalVariables().KUserDefaults?.integer(forKey: "notificationsGrouping") else { return 0 }
		return notificationsGrouping
	}

	/// Returns if notifications sound is allowed saved in KUserDefaults
	static func notificationsSound() -> Bool {
		guard let notificationsSound = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsSound") else { return true }
		return notificationsSound
	}

	/// Returns if notifications vibration is allowed saved in KUserDefaults
	static func notificationsVibration() -> Bool {
		guard let notificationsVibration = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsVibration") else { return true }
		return notificationsVibration
	}

	/// Returns if notifications badge is allowed saved in KUserDefaults
	static func notificationsBadge() -> Bool {
		guard let notificationsBadge = GlobalVariables().KUserDefaults?.bool(forKey: "notificationsBadge") else { return true }
		return notificationsBadge
	}

	/// Returns if notifications badge is allowed saved in KUserDefaults
	static func alertType() -> Int {
		guard let alertType = GlobalVariables().KUserDefaults?.integer(forKey: "alertType") else { return 0 }
		return alertType
	}
}
