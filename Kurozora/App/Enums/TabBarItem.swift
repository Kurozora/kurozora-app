//
//  TabBarItem.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// The set of available tab bar items.
enum TabBarItem: Int, CaseIterable {
	// MARK: - Cases
	/// Representing the home tab.
	case home = 0

	/// Representing the library tab.
	case library

	/// Representing the feed tab.
	case feed

	/// Representing the notification tab.
	case notifications

	/// Representing the search tab.
	case search

	/// Representing the settings tab.
	case settings

	// MARK: - Properties
	static var sideBarCases: [TabBarItem] {
		#if targetEnvironment(macCatalyst)
		return [.home, .library, .feed, .notifications, .settings]
		#else
		return [.home, .library, .feed, .notifications, .search, .settings]
		#endif
	}

	static var tabBarCases: [TabBarItem] {
		return [.home, .library, .feed, .notifications, .search]
	}

	// MARK: - Structs
	/// List of row identifiers.
	private struct RowIdentifier {
		/// The unique identifier for the home tab.
		static let home = UUID()

		/// The unique identifier for the library tab.
		static let library = UUID()

		/// The unique identifier for the feed tab.
		static let feed = UUID()

		/// The unique identifier for the notification tab.
		static let notifications = UUID()

		/// The unique identifier for the search tab.
		static let search = UUID()

		/// The unique identifier for the settings tab.
		static let settings = UUID()
	}

	// MARK: - Properties
	/// The string value of the tab bar item.
	var stringValue: String {
		switch self {
		case .home:
			return Trans.explore
		case .library:
			return Trans.library
		case .feed:
			return Trans.feed
		case .notifications:
			return Trans.notifications
		case .search:
			return Trans.search
		case .settings:
			return Trans.settings
		}
	}

	/// The image value of the tab bar item.
	var imageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house")!
		case .library:
			return UIImage(systemName: "rectangle.stack")!
		case .feed:
			return UIImage(systemName: "person.crop.circle")!
		case .notifications:
			return UIImage(systemName: "app.badge")!
		case .search:
			return UIImage(systemName: "magnifyingglass")!
		case .settings:
			return UIImage(systemName: "gear")!
		}
	}

	/// The selected image value of the tab bar item.
	var selectedImageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house.fill")!
		case .library:
			return UIImage(systemName: "rectangle.stack.fill")!
		case .feed:
			return UIImage(systemName: "person.crop.circle.fill")!
		case .notifications:
			return UIImage(systemName: "app.badge.fill")!
		case .search:
			return UIImage(systemName: "text.magnifyingglass")!
		case .settings:
			return UIImage(systemName: "gear")!
		}
	}

	/// The view controller value of the tab bar item.
	var viewControllerValue: UIViewController {
		switch self {
		case .home:
			return R.storyboard.home.homeCollectionViewController()!
		case .library:
			return R.storyboard.library.libraryViewController()!
		case .feed:
			return R.storyboard.feed.feedTableViewController()!
		case .notifications:
			return R.storyboard.notifications.notificationsTableViewController()!
		case .search:
			return R.storyboard.search.searchResultsCollectionViewController()!
		case .settings:
			return R.storyboard.settings.settingsSplitViewController()!
		}
	}

	/// The navigation controller value of the tab bar item.
	var kViewControllerValue: UIViewController {
		switch self {
		case .home:
			return R.storyboard.home.homeKNavigationController()!
		case .library:
			return R.storyboard.library.libraryKNavigationController()!
		case .feed:
			return R.storyboard.feed.feedTableKNavigationController()!
		case .notifications:
			return R.storyboard.notifications.notificationKNvaigationController()!
		case .search:
			return R.storyboard.search.searchKNvaigationController()!
		case .settings:
			return R.storyboard.settings.instantiateInitialViewController()!
		}
	}

	/// The unique row identifier value of the tab bar item.
	var rowIdentifierValue: UUID {
		switch self {
		case .home:
			return RowIdentifier.home
		case .library:
			return RowIdentifier.library
		case .feed:
			return RowIdentifier.feed
		case .notifications:
			return RowIdentifier.notifications
		case .search:
			return RowIdentifier.search
		case .settings:
			return RowIdentifier.settings
		}
	}
}
