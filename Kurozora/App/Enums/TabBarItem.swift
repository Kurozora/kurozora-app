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

	/// Representing the schedule tab.
	case schedule

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

	// MARK: - Initializers
	@available(iOS 18.0, macCatalyst 18.0, *)
	init?(identifierValue: String) {
		guard let tabBarItem = TabBarItem.allCases.first(where: {
			$0.rowIdentifierValue == identifierValue
		}) else { return nil }

		self = tabBarItem
	}

	// MARK: - Properties
	static var sideBarCases: [TabBarItem] {
		#if targetEnvironment(macCatalyst)
		return [.home, .schedule, .library, .feed, .notifications, .settings]
		#else
		return [.home, .schedule, .library, .feed, .notifications, .search, .settings]
		#endif
	}

	static var tabBarCases: [TabBarItem] {
		if #available(iOS 18.0, macCatalyst 18.0, *) {
			#if targetEnvironment(macCatalyst)
			return [.search, .home, .schedule, .library, .feed, .notifications, .settings]
			#endif

			if UIDevice.isPad {
				return [.search, .home, .schedule, .library, .feed, .notifications, .settings]
			}
		}

		return self.compactTabBarCases
	}

	static var compactTabBarCases: [TabBarItem] {
		return [.home, .library, .feed, .notifications, .search]
	}

	/// The string value of the tab bar item.
	var stringValue: String {
		switch self {
		case .home:
			return Trans.explore
		case .schedule:
			return Trans.schedule
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
		case .schedule:
			return UIImage(systemName: "calendar")!
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
		case .schedule:
			return #imageLiteral(resourceName: "Symbols/calendar.fill")
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
			return HomeCollectionViewController.instantiate()
		case .schedule:
			return ScheduleCollectionViewController.instantiate()
		case .library:
			return LibraryViewController.instantiate()
		case .feed:
			return FeedTableViewController.instantiate()
		case .notifications:
			return NotificationsTableViewController.instantiate()
		case .search:
			return SearchResultsCollectionViewController.instantiate()
		case .settings:
			return SettingsSplitViewController.instantiate()
		}
	}

	/// The navigation controller value of the tab bar item.
	var kViewControllerValue: UIViewController {
		switch self {
		case .home:
			let homeCollectionViewController = HomeCollectionViewController.instantiate()
			return KNavigationController(rootViewController: homeCollectionViewController)
		case .schedule:
			let scheduleCollectionViewController = ScheduleCollectionViewController.instantiate()
			return KNavigationController(rootViewController: scheduleCollectionViewController)
		case .library:
			let libraryViewController = LibraryViewController.instantiate()
			return KNavigationController(rootViewController: libraryViewController)
		case .feed:
			let feedTableViewController = FeedTableViewController.instantiate()
			return KNavigationController(rootViewController: feedTableViewController)
		case .notifications:
			let notificationsTableViewController = NotificationsTableViewController.instantiate()
			return KNavigationController(rootViewController: notificationsTableViewController)
		case .search:
			let searchResultsCollectionViewController = SearchResultsCollectionViewController.instantiate()
			return KNavigationController(rootViewController: searchResultsCollectionViewController)
		case .settings:
			return SettingsSplitViewController.instantiate()
		}
	}

	/// The unique row identifier value of the tab bar item.
	@available(iOS 18.0, macCatalyst 18.0, *)
	var rowIdentifierValue: String {
		return String(describing: self)
	}

	/// A tab’s placement when displayed in contexts that allow different placement.
	@available(iOS 18.0, macCatalyst 18.0, *)
	var tabPlacement: UITab.Placement {
		switch self {
		case .home, .library, .feed, .notifications:
			return .fixed
		case .search:
			return .pinned
		default:
			return .optional
		}
	}

	/// The tab value of the tab bar item.
	@available(iOS 18.0, macCatalyst 18.0, *)
	var tab: UITab {
		switch self {
		case .search:
			let tab = UISearchTab(
				title: self.stringValue,
				image: self.imageValue,
				identifier: self.rowIdentifierValue
			) { _ in
				self.kViewControllerValue
			}
			tab.preferredPlacement = self.tabPlacement
			return tab
		default:
			let tab = UITab(
				title: self.stringValue,
				image: self.imageValue,
				identifier: self.rowIdentifierValue
			) { _ in
				self.kViewControllerValue
			}
			tab.preferredPlacement = self.tabPlacement
			return tab
		}
	}
}
