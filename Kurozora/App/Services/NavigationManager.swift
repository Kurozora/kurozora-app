//
//  NavigationManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Combine

@MainActor
class NavigationManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `NavigationManager`.
	static let shared = NavigationManager()

	/// The set of cancellable
	private var subscriptions = Set<AnyCancellable>()

	/// Whether a song is playing.
	@Published var selectedDestination: URL? = nil

	// MARK: - Initializers
	private override init() {
		super.init()

		self.$selectedDestination.sink { [weak self] url in
			guard let self = self, let url = url else { return }
			self.routeScheme(with: url)
		}
		.store(in: &self.subscriptions)
	}

	/// Routes the scheme with the specified url to an in app resource.
	///
	/// - Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	fileprivate func routeScheme(with url: URL) {
		if url.pathExtension == "xml" {
			WorkflowController.shared.isSignedIn {
				let topViewController = UIApplication.topViewController
				if let libraryImportTableViewController = topViewController as? LibraryImportTableViewController {
					libraryImportTableViewController.selectedFileURL = url
				} else if let kNavigationController = (topViewController as? SettingsSplitViewController)?.viewControllers[1] as? KNavigationController {
					if let libraryImportTableViewController = kNavigationController.topViewController as? LibraryImportTableViewController {
						libraryImportTableViewController.selectedFileURL = url
					} else if let libraryImportTableViewController = R.storyboard.accountSettings.libraryImportTableViewController() {
						libraryImportTableViewController.selectedFileURL = url
						kNavigationController.show(libraryImportTableViewController, sender: nil)
					}
				} else if let libraryImportTableViewController = R.storyboard.accountSettings.libraryImportTableViewController() {
					let closeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: libraryImportTableViewController, action: #selector(libraryImportTableViewController.dismissButtonPressed))
					libraryImportTableViewController.navigationItem.leftBarButtonItem = closeBarButtonItem
					libraryImportTableViewController.selectedFileURL = url
					let kNavigationController = KNavigationController(rootViewController: libraryImportTableViewController)
					topViewController?.show(kNavigationController, sender: nil)
				}
			}
		}

		guard let urlScheme = url.host?.removingPercentEncoding else { return }
		guard let scheme: Scheme = Scheme(rawValue: urlScheme) else { return }
		let parameters: [String: String] = url.queryParameters ?? [:]

		switch scheme {
		case .anime, .show, .shows:
			let showID = url.lastPathComponent
			if !showID.isEmpty {
				let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
				UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
			}
		case .game, .games:
			let gameID = url.lastPathComponent
			if !gameID.isEmpty {
				let gameDetailsCollectionViewController = GameDetailsCollectionViewController.`init`(with: gameID)
				UIApplication.topViewController?.show(gameDetailsCollectionViewController, sender: nil)
			}
		case .manga, .literature, .literatures:
			let literatureID = url.lastPathComponent
			if !literatureID.isEmpty {
				let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController.`init`(with: literatureID)
				UIApplication.topViewController?.show(literatureDetailsCollectionViewController, sender: nil)
			}
		case .profile, .user:
			let lastPathComponent = url.lastPathComponent
			guard let userID = lastPathComponent.isEmpty ? User.current?.id : lastPathComponent else { return }
			let profileTableViewController = ProfileTableViewController.`init`(with: userID)

			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedViewController?.show(profileTableViewController, sender: nil)
			} else {
				UIApplication.topViewController?.show(profileTableViewController, sender: nil)
			}
		case .explore, .home:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = TabBarItem.home.rawValue
			}
		case .schedule:
			if UIDevice.isPhone {
				guard let scheduleCollectionViewController = R.storyboard.schedule.scheduleCollectionViewController() else { return }
				UIApplication.topViewController?.show(scheduleCollectionViewController, sender: nil)
			} else {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = TabBarItem.schedule.rawValue
			}
		case .library, .myLibrary, .list:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = TabBarItem.library.rawValue
			}
		case .feed, .timeline:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = TabBarItem.feed.rawValue
			}
		case .notification, .notifications:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = TabBarItem.notifications.rawValue
			}
		case .search:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let kTabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				guard let kNavigationController = kTabBarController.viewControllers?[safe: 4] as? KNavigationController else { return }
				guard let searchResultsCollectionViewController = kNavigationController.topViewController as? SearchResultsCollectionViewController else { return }

				kTabBarController.selectedIndex = TabBarItem.search.rawValue
				self.handleSearchDeeplink(
					on: searchResultsCollectionViewController,
					searchController: searchResultsCollectionViewController.kSearchController,
					parameters: parameters
				)
			} else {
				DispatchQueue.main.async {
					guard let splitViewController = UIApplication.topViewController?.splitViewController else { return }
					guard let navigationController = splitViewController.viewController(for: .primary) as? KNavigationController else { return }
					guard let sidebarViewController = navigationController.topViewController as? SidebarViewController else { return }

					self.handleSearchDeeplink(
						on: sidebarViewController.searchResultsCollectionViewController,
						searchController: sidebarViewController.kSearchController,
						parameters: parameters
					)
				}
			}
		}
	}

	/// Handles deeplinking to the search view.
	///
	/// - Parameters:
	///    - viewController: An instance of `SearchResultsCollectionViewController` to deeplink to.
	///    - searchController: An instance of `KSearchController` to perform the search if required.
	///    - parameters: The parameters used for performing the search.
	fileprivate func handleSearchDeeplink(
		on viewController: SearchResultsCollectionViewController,
		searchController: KSearchController,
		parameters: [String: String]
	) {
		let queryString = parameters["q"] ?? ""
		let scopeString = Int(parameters["scope"] ?? "0")
		let typeString = parameters["type"] ?? KKSearchType.shows.rawValue
		let scope: KKSearchScope = if let scopeString = scopeString {
			KKSearchScope(rawValue: scopeString) ?? .kurozora
		} else {
			.kurozora
		}
		let type: KKSearchType = KKSearchType(rawValue: typeString) ?? .shows

		if parameters.isEmpty {
			searchController.searchBar.textField?.becomeFirstResponder()
		} else if !queryString.isEmpty {
			viewController.searachQuery = queryString
			viewController.currentScope = scope
			viewController.currentTypes = [type]
			searchController.searchBar.textField?.text = queryString
			searchController.searchBar.selectedScopeButtonIndex = scope.rawValue

			if viewController.dataSource == nil {
				viewController.isDeepLinked = true
				searchController.searchBar.textField?.resignFirstResponder()
				searchController.searchBar.textField?.resignFirstResponder()
			} else {
				viewController.performSearch(with: queryString, in: scope, for: [type], with: nil, next: nil, resettingResults: true)
			}
		}
	}

	/// Opens a resource specified by a URL.
	///
	/// - Parameters:
	///    - scene: The object that represents one instance of the app's user interface.
	///    - url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	func schemeHandler(_ scene: UIScene, open url: URL) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.routeScheme(with: url)
		}
	}
}
