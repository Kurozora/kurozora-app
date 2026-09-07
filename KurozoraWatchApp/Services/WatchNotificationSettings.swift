//
//  WatchNotificationSettings.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import Observation

/// The grouping style for notifications on the watch, mirroring `KNotification.GroupStyle` raw values.
enum WatchGroupStyle: Int, CaseIterable {
	/// Groups notifications in sections by date and time.
	case automatic = 0

	/// Groups notifications in sections by notification type.
	case byType = 1

	/// Shows all notifications in a single flat list.
	case off = 2

	/// The display label for this group style.
	var label: String {
		switch self {
		case .automatic:
			return L10n.groupingAutomatic
		case .byType:
			return L10n.groupingByType
		case .off:
			return L10n.groupingOff
		}
	}
}

/// The watch's notification grouping settings.
///
/// Grouping either mirrors the value pushed from the iPhone or uses a watch-local one.
///
/// - Important: Mutate only through the setter methods. `@Observable` replaces the stored
/// property accessors, so `didSet` never fires.
@MainActor @Observable
final class WatchNotificationSettings {
	// MARK: - Keys
	private enum Keys {
		static let mirrorWatch = "notificationsMirrorWatch"
		static let localGrouping = "watchNotificationsGrouping"
	}

	// MARK: - Properties
	/// Whether the watch mirrors the iPhone's notification grouping setting.
	private(set) var isMirroringIPhone: Bool = true

	/// The watch-local grouping value, used when not mirroring the iPhone.
	private(set) var watchLocalGrouping: Int = 0

	/// The most recent grouping value received from the iPhone via WatchConnectivity.
	private(set) var mirroredGrouping: Int = 0

	/// The effective grouping style applied for rendering.
	var effectiveGroupStyle: WatchGroupStyle {
		let rawValue = self.isMirroringIPhone ? self.mirroredGrouping : self.watchLocalGrouping
		return WatchGroupStyle(rawValue: rawValue) ?? .automatic
	}

	// MARK: - Initializers
	init() {
		// Default to mirroring the iPhone on first launch.
		UserDefaults.standard.register(defaults: [
			Keys.mirrorWatch: true,
			Keys.localGrouping: WatchGroupStyle.automatic.rawValue
		])
		self.isMirroringIPhone = UserDefaults.standard.bool(forKey: Keys.mirrorWatch)
		self.watchLocalGrouping = UserDefaults.standard.integer(forKey: Keys.localGrouping)
	}

	// MARK: - Functions
	/// Sets whether the watch mirrors the iPhone's notification grouping and persists the value.
	func setMirroring(_ value: Bool) {
		self.isMirroringIPhone = value
		UserDefaults.standard.set(value, forKey: Keys.mirrorWatch)
	}

	/// Sets the watch-local grouping value and persists it.
	func setLocalGrouping(_ value: Int) {
		self.watchLocalGrouping = value
		UserDefaults.standard.set(value, forKey: Keys.localGrouping)
	}

	/// Applies notification settings received from the iPhone via WatchConnectivity.
	///
	/// - Parameters:
	///   - grouping: The iPhone's notification grouping raw value, if present.
	///   - mirrorWatch: Whether the iPhone wants the watch to mirror its setting, if present.
	func applyContext(grouping: Int?, mirrorWatch: Bool?) {
		if let grouping {
			self.mirroredGrouping = grouping
		}
		if let mirrorWatch {
			self.setMirroring(mirrorWatch)
		}
	}
}
