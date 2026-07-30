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

	// Appended last so the existing raw values, which `KTabBarController` treats as
	// tab-bar indices before iOS 18, keep pointing at the same tabs.
	/// Representing the Kotodama tab.
	case kotodama

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
		return [.home, .schedule, .kotodama, .library, .feed, .notifications, .settings]
		#else
		return [.home, .schedule, .kotodama, .library, .feed, .notifications, .search, .settings]
		#endif
	}

	static var tabBarCases: [TabBarItem] {
		if #available(iOS 18.0, macCatalyst 18.0, *) {
			#if targetEnvironment(macCatalyst)
			return [.search, .home, .schedule, .kotodama, .library, .feed, .notifications, .settings]
			#else
			if UIDevice.isPad {
				return [.search, .home, .schedule, .kotodama, .library, .feed, .notifications, .settings]
			}
			#endif
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
			return L10n.explore
		case .schedule:
			return L10n.schedule
		case .kotodama:
			return L10n.kotodama
		case .library:
			return L10n.library
		case .feed:
			return L10n.feed
		case .notifications:
			return L10n.notifications
		case .search:
			return L10n.search
		case .settings:
			return L10n.settings
		}
	}

	/// The image value of the tab bar item.
	var imageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house")!
		case .schedule:
			return UIImage(systemName: "calendar")!
		case .kotodama:
			return UIImage(systemName: "gamecontroller")!
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
			return .Symbols.calendarFill
		case .kotodama:
			return UIImage(systemName: "gamecontroller.fill")!
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
			return HomeCollectionViewController()
		case .schedule:
			return ScheduleCollectionViewController()
		case .kotodama:
			return KotodamaHubCollectionViewController()
		case .library:
			return LibraryViewController()
		case .feed:
			return FeedTableViewController()
		case .notifications:
			return NotificationsTableViewController()
		case .search:
			return SearchResultsCollectionViewController()
		case .settings:
			return SettingsSplitViewController()
		}
	}

	/// The navigation controller value of the tab bar item.
	var kViewControllerValue: UIViewController {
		let viewController = self.viewControllerValue

		switch self {
		case .home, .schedule, .kotodama, .library, .feed, .notifications, .search:
			return KNavigationController(rootViewController: viewController)
		case .settings:
			return viewController
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
