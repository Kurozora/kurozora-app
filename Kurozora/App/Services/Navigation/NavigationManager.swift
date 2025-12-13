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

/// Manage in-app navigation based on URL schemes.
@MainActor
final class NavigationManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `NavigationManager`.
	static let shared = NavigationManager()

	/// The set of cancellable subscriptions.
	private var subscriptions = Set<AnyCancellable>()

	/// The selected destination URL.
	@Published var selectedDestination: URL?

	// MARK: - Initializers
	override private init() {
		super.init()

		self.$selectedDestination
			.compactMap { $0 }
			.sink { [weak self] url in
				guard let self = self else { return }

				Task {
					await self.routeScheme(with: url, on: nil)
				}
			}
			.store(in: &self.subscriptions)
	}

	/// Creates a navigation context from the specified scene.
	///
	/// - Parameter scene: The scene to create the navigation context from.
	///
	/// - Returns: The navigation context if it could be created, otherwise `nil`.
	private func navigationContext(from scene: UIScene?) -> NavigationContext? {
		if let scene = scene as? UIWindowScene {
			return NavigationContext(scene: scene)
		}

		return UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.first(where: { $0.activationState == .foregroundActive })
			.flatMap { NavigationContext(scene: $0) }
	}

	/// Routes the scheme with the specified url to an in app resource.
	///
	/// - Parameters:
	///    - url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	///    - scene: The scene to present the resource on. If `nil`, the active scene will be used.
	private func routeScheme(with url: URL, on scene: UIScene?) async {
		if url.pathExtension == "xml" {
			await self.handleFileImport(from: url, on: scene)
		}

		guard
			let host = url.host?.removingPercentEncoding,
			let scheme = Scheme(rawValue: host)
		else { return }

		let parameters = url.queryParameters ?? [:]
		let lastPathComponent = url.lastPathComponent
		guard let context = self.navigationContext(from: scene) else { return }

		switch scheme {
		case .anime, .show, .shows:
			guard !lastPathComponent.isEmpty else { return }
			let showID = KurozoraItemID(lastPathComponent)
			let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
			context.show(showDetailsCollectionViewController)
		case .game, .games:
			guard !lastPathComponent.isEmpty else { return }
			let gameID = KurozoraItemID(lastPathComponent)
			let gameDetailsCollectionViewController = GameDetailsCollectionViewController.`init`(with: gameID)
			context.show(gameDetailsCollectionViewController)
		case .manga, .literature, .literatures:
			guard !lastPathComponent.isEmpty else { return }
			let literatureID = KurozoraItemID(lastPathComponent)
			let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController.`init`(with: literatureID)
			context.show(literatureDetailsCollectionViewController)
		case .profile, .user:
			guard let userID = lastPathComponent.isEmpty ? User.current?.id : KurozoraItemID(lastPathComponent) else { return }
			let profileTableViewController = ProfileTableViewController.`init`(with: userID)
			context.show(profileTableViewController)
		case .home, .explore:
			context.selectTab(.home)
		case .schedule:
			context.selectTab(.schedule)
		case .library, .myLibrary, .list:
			context.selectTab(.library)
		case .feed, .timeline:
			context.selectTab(.feed)
		case .notification, .notifications:
			context.selectTab(.notifications)
		case .search:
			context.activateSearch { viewController, searchController in
				self.handleSearchDeeplink(
					on: viewController,
					searchController: searchController,
					parameters: parameters
				)
			}
		}
	}

	/// Handles file import for the given URL.
	///
	/// - Parameters:
	///    - url: The URL of the file to import.
	///    - scene: The scene to present the import on. If `nil`, the active scene will be used.
	private func handleFileImport(from url: URL, on scene: UIScene?) async {
		guard await WorkflowController.shared.isSignedIn() else { return }
		guard let context = self.navigationContext(from: scene) else { return }

		if let existing = context.topViewController as? LibraryImportTableViewController {
			existing.selectedFileURL = url
			return
		}

		let controller = R.storyboard.accountSettings.libraryImportTableViewController()
		controller?.selectedFileURL = url
		context.show(controller)
	}

	/// Handles deeplinking to the search view.
	///
	/// - Parameters:
	///    - viewController: An instance of `SearchResultsCollectionViewController` to deeplink to.
	///    - searchController: An instance of `KSearchController` to perform the search if required.
	///    - parameters: The parameters used for performing the search.
	private func handleSearchDeeplink(
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
			return
		}

		guard !queryString.isEmpty else { return }

		viewController.searchQuery = queryString
		viewController.currentScope = scope
		viewController.currentTypes = [type]
		searchController.searchBar.searchTextField.text = queryString
		searchController.searchBar.selectedScopeButtonIndex = scope.rawValue

		if viewController.dataSource == nil {
			viewController.isDeepLinked = true
			searchController.searchBar.searchTextField.resignFirstResponder()
		} else {
			viewController.performSearch(with: queryString, in: scope, for: [type], with: nil, next: nil, resettingResults: true)
		}
	}

	/// Handles opening a URL scheme.
	///
	/// - Parameters:
	///    - scene: The scene to open the URL on.
	///    - url: The URL to open.
	func schemeHandler(_ scene: UIScene, open url: URL) async {
		await self.routeScheme(with: url, on: scene)
	}

	/// Handles opening a `Scheme`.
	///
	/// - Parameters:
	///    - scene: The scene to open the scheme on.
	///    - scheme: The scheme to open.
	func schemeHandler(_ scene: UIScene, open scheme: Scheme) async {
		await self.routeScheme(with: scheme.urlValue, on: scene)
	}
}
