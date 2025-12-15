//
//  HomeScreenShortcutItem.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// The set of available home screen shortcut items.
enum HomeScreenShortcutItem: String, CaseIterable {
	// MARK: - Cases
	/// The shortcut indicating search.
	case search

	/// The shortcut indicating a user's library.
	case library

	/// The shortcut indicating a user's profile.
	case profile

	/// The shortcut indicating notifications.
	case notifications

	// MARK: - Initializers
	/// Initializes a `HomeScreenShortcutItem` from a given type identifier.
	///
	/// - Parameter type: The type identifier of the shortcut item.
	init?(type: String) {
		let prefix = "\(Self.bundleID)."
		guard type.hasPrefix(prefix) else { return nil }
		self.init(rawValue: String(type.dropFirst(prefix.count)))
	}

	// MARK: - Properties
	/// The bundle identifier of the app.
	private static let bundleID = Bundle.main.bundleIdentifier!

	/// The type identifier for the shortcut item.
	var type: String {
		"\(Self.bundleID).\(rawValue)"
	}

	/// The title for the shortcut item.
	var title: String {
		switch self {
		case .search: return Trans.search
		case .library: return Trans.library
		case .profile: return Trans.profile
		case .notifications: return Trans.notifications
		}
	}

	/// The icon for the shortcut item.
	var icon: UIApplicationShortcutIcon? {
		switch self {
		case .search: return .init(systemImageName: "magnifyingglass")
		case .library: return .init(systemImageName: "rectangle.stack")
		case .profile: return .init(systemImageName: "person.crop.circle")
		case .notifications: return .init(systemImageName: "app.badge")
		}
	}
}

// MARK: - UIApplicationShortcutItem
extension HomeScreenShortcutItem {
	/// The `UIApplicationShortcutItem` representation of the home screen shortcut item.
	var shortcutItem: UIApplicationShortcutItem {
		UIApplicationShortcutItem(
			type: self.type,
			localizedTitle: self.title,
			localizedSubtitle: nil,
			icon: self.icon,
			userInfo: nil
		)
	}
}
