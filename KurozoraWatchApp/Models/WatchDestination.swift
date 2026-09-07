//
//  WatchDestination.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// A screen reachable from the watch app's root list.
enum WatchDestination: Hashable, Identifiable {
	/// The Up Next queue, pushed automatically on launch.
	case home

	/// The signed in user's library.
	case library

	/// Catalog search.
	case search

	/// The signed in user's profile.
	case profile

	// MARK: - Properties
	/// The destinations listed as rows on the root screen.
	static let rows: [WatchDestination] = [.home, .library, .search]

	var id: Self {
		return self
	}

	/// The title shown on the root row and in the destination's navigation bar.
	var title: String {
		switch self {
		case .home:
			return L10n.home
		case .library:
			return L10n.library
		case .search:
			return L10n.search
		case .profile:
			return L10n.profile
		}
	}

	/// The symbol shown alongside the title on the root row.
	var symbolName: String {
		switch self {
		case .home:
			return "house.fill"
		case .library:
			return "rectangle.stack.fill"
		case .search:
			return "magnifyingglass"
		case .profile:
			return "person.crop.circle.fill"
		}
	}
}
