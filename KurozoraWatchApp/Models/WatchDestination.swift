//
//  WatchDestination.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// A screen the watch app's navigation stack can push.
enum WatchDestination: Hashable, Identifiable {
	/// The Up Next queue, pushed automatically on launch.
	case home

	/// The signed in user's library.
	case library

	/// The matches for a submitted search query.
	case searchResults(query: String)

	/// The signed in user's profile.
	case profile

	// MARK: - Properties
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
		case .searchResults(let query):
			return query
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
		case .searchResults:
			return "magnifyingglass"
		case .profile:
			return "person.crop.circle.fill"
		}
	}
}
