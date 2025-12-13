//
//  NavigationContext.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// A context for navigation within the app.
@MainActor
struct NavigationContext {
	// MARK: - Properties
	/// The scene associated with the navigation context.
	let scene: UIWindowScene

	/// The window associated with the navigation context.
	let window: UIWindow

	/// The root view controller of the window.
	let rootViewController: UIViewController

	// MARK: - Initializers
	/// Creates a navigation context from the specified scene.
	///
	/// - Parameter scene: The scene to create the navigation context from.
	init?(scene: UIWindowScene) {
		guard let window = scene.windows.first(where: { $0.isKeyWindow }) else { return nil }
		self.scene = scene
		self.window = window
		self.rootViewController = window.rootViewController!
	}

	/// The split view controller of the navigation context.
	var splitViewController: UISplitViewController? {
		self.rootViewController as? UISplitViewController
	}

	/// The tab bar controller of the navigation context.
	var tabBarController: KTabBarController? {
		(self.splitViewController?.viewController(for: .compact) ??
			self.splitViewController?.viewController(for: .primary) ??
			self.rootViewController) as? KTabBarController
	}

	/// The navigation controller of the navigation context.
	var navigationController: UINavigationController? {
		self.tabBarController?.selectedViewController as? UINavigationController
	}

	/// The top view controller of the navigation context.
	var topViewController: UIViewController? {
		self.navigationController?.topViewController
	}

	/// Shows the specified view controller.
	func show(_ viewController: UIViewController?) {
		guard let viewController else { return }
		self.navigationController?.show(viewController, sender: nil)
	}

	/// Selects the specified tab.
	func selectTab(_ tabItem: TabBarItem) {
		self.tabBarController?.selectTab(tabItem)
	}

	/// Activates the search tab and provides the search results view controller and search controller to the handler.
	///
	/// - Parameter handler: A closure that's called after the search tab is activated.
	func activateSearch(_ handler: (SearchResultsCollectionViewController, KSearchController) -> Void) {
		self.selectTab(.search)

		guard
			let nav = navigationController,
			let results = nav.topViewController as? SearchResultsCollectionViewController
		else { return }

		handler(results, results.kSearchController)
	}
}
