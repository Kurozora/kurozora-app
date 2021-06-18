//
//  SceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var isUnreachable = false

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		// Initialize UIWindow
		window = UIWindow(windowScene: windowScene)
		window?.makeKeyAndVisible()

		// Initialize theme
		KThemeStyle.initAppTheme()

		#if targetEnvironment(macCatalyst)
		// Hide the title bar
		if let titlebar = windowScene.titlebar {
			titlebar.titleVisibility = .hidden
			titlebar.toolbar = nil
		}
		windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1000, height: 432)
		#endif

		// Global app tint color
		self.window?.theme_tintColor = KThemePicker.tintColor.rawValue

		// If the network is unreachable show the offline page
		KNetworkManager.isUnreachable { _ in
			self.isUnreachable = true
		}

		// Check network availability
		if isUnreachable {
			KurozoraDelegate.shared.showOfflinePage(for: window)
			return
		}

		// Initialize tab bar controller
		if #available(iOS 14.0, macOS 11.0, *) {
			let splitViewController = self.createTwoColumnSplitViewController()
			self.window?.rootViewController = splitViewController
		} else {
			self.window?.rootViewController = KTabBarController()
		}

		// Check if user should authenticate
		KurozoraDelegate.shared.userHasToAuthenticate()

		// Configure window or resotre previous activity.
		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			 if !configure(window: window, with: userActivity) {
				print("Failed to restore from \(userActivity)")
			 }
		}
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		KurozoraDelegate.shared.schemeHandler(scene, open: url)
	}

	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		KurozoraDelegate.shared.shortcutHandler(windowScene, performActionFor: shortcutItem)
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		KurozoraDelegate.shared.userShouldAuthenticate()
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		KNetworkManager.isReachable { _ in
			if User.isSignedIn {
				WorkflowController.shared.registerForPushNotifications()
			}
		}

		if UserSettings.automaticDarkTheme {
			KThemeStyle.checkAutomaticSchedule()
		}
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		if Date.uptime() > KurozoraDelegate.shared.authenticationInterval, KurozoraDelegate.shared.authenticationEnabled {
			KurozoraDelegate.shared.prepareForAuthentication()
		}

		// Clear notifications
		UIApplication.shared.applicationIconBadgeNumber = 0
	}

	// MARK: - Functions
	/**
		Configures the scene according to the passed activity.

		- Parameter window: The backdrop for your app’s user interface and the object that dispatches events to your views.
		- Parameter activity: A representation of the state of your app at a moment in time.
	*/
    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if activity.title == "OpenShowDetail" {
			if let parameters = activity.userInfo as? [String: Int] {
				guard let showID = parameters["showID"] else { return false }
				let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
				if let tabBarController = window?.rootViewController as? KTabBarController {
					tabBarController.present(showDetailsCollectionViewController, animated: true)
					return true
				}
            }
        }
        return false
    }

	@available(iOS 14.0, macOS 11.0, *)
	private func createTwoColumnSplitViewController() -> UISplitViewController {
		let sidebarViewController = UINavigationController(rootViewController: SidebarViewController())
		let tabBarController = KTabBarController()
		let splitViewController = UISplitViewController(style: .doubleColumn)
		splitViewController.primaryBackgroundStyle = .sidebar
		splitViewController.preferredDisplayMode = .oneBesideSecondary
		if #available(macCatalyst 14.5, *) {
			splitViewController.displayModeButtonVisibility = .never
		} else {
			// Fallback on earlier versions
		}
		splitViewController.minimumPrimaryColumnWidth = 220.0
		splitViewController.maximumPrimaryColumnWidth = 220.0
		splitViewController.setViewController(sidebarViewController, for: .primary)
		splitViewController.setViewController(tabBarController, for: .compact)
		return splitViewController
	}
}
