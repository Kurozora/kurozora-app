//
//  NavigationManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import UIKit

@MainActor
class NavigationManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `NavigationManager`.
	static let shared = NavigationManager()

	/// The set of cancellable
	private var subscriptions = Set<AnyCancellable>()

	/// Whether a song is playing.
	@Published var selectedDestination: URL?

	// MARK: - Initializers
	override private init() {
		super.init()

		self.$selectedDestination.sink { [weak self] url in
			guard let self = self, let url = url else { return }

			Task {
				await self.routeScheme(with: url)
			}
		}
		.store(in: &self.subscriptions)
	}

	/// Routes the scheme with the specified url to an in app resource.
	///
	/// - Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	fileprivate func routeScheme(with url: URL) async {
		if url.pathExtension == "xml" {
			await self.handleFileImport(from: url)
		}

		guard
			let urlScheme = url.host?.removingPercentEncoding,
			let scheme: Scheme = Scheme(rawValue: urlScheme)
		else { return }
		let parameters: [String: String] = url.queryParameters ?? [:]
		let lastPathComponent = url.lastPathComponent

		switch scheme {
		case .anime, .show, .shows:
			if !lastPathComponent.isEmpty {
				let showID = KurozoraItemID(lastPathComponent)
				let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
				UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
			}
		case .game, .games:
			if !lastPathComponent.isEmpty {
				let gameID = KurozoraItemID(lastPathComponent)
				let gameDetailsCollectionViewController = GameDetailsCollectionViewController.`init`(with: gameID)
				UIApplication.topViewController?.show(gameDetailsCollectionViewController, sender: nil)
			}
		case .manga, .literature, .literatures:
			if !lastPathComponent.isEmpty {
				let literatureID = KurozoraItemID(lastPathComponent)
				let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController.`init`(with: literatureID)
				UIApplication.topViewController?.show(literatureDetailsCollectionViewController, sender: nil)
			}
		case .profile, .user:
			guard let userID = lastPathComponent.isEmpty ? User.current?.id : KurozoraItemID(lastPathComponent) else { return }
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
				tabBarController.selectTab(.home)
			}
		case .schedule:
			if UIDevice.isPhone {
				guard let scheduleCollectionViewController = R.storyboard.schedule.scheduleCollectionViewController() else { return }
				UIApplication.topViewController?.show(scheduleCollectionViewController, sender: nil)
			} else {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectTab(.schedule)
			}
		case .library, .myLibrary, .list:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectTab(.library)
			}
		case .feed, .timeline:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectTab(.feed)
			}
		case .notification, .notifications:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectTab(.notifications)
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

	/// Handles file import for the given URL.
	///
	/// - Parameter url: The URL of the file to import.
	fileprivate func handleFileImport(from url: URL) async {
		let signedIn = await WorkflowController.shared.isSignedIn()
		guard signedIn else { return }

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
			searchController.searchBar.searchTextField.becomeFirstResponder()
		} else if !queryString.isEmpty {
			viewController.searchQuery = queryString
			viewController.currentScope = scope
			viewController.currentTypes = [type]
			searchController.searchBar.searchTextField.text = queryString
			searchController.searchBar.selectedScopeButtonIndex = scope.rawValue

			if viewController.dataSource == nil {
				viewController.isDeepLinked = true
				searchController.searchBar.searchTextField.resignFirstResponder()
				searchController.searchBar.searchTextField.resignFirstResponder()
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
	func schemeHandler(_ scene: UIScene, open url: URL) async {
		await self.routeScheme(with: url)
	}
}
