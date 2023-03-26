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
	var authenticationCount = 0
	var isUnreachable = false

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		print("----- Scene will connect to session.")
		guard let windowScene = (scene as? UIWindowScene) else { return }

		// Initialize UIWindow
		self.window = UIWindow(windowScene: windowScene)
		self.window?.makeKeyAndVisible()

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

		// Monitor network availability
		KNetworkManager.shared.reachability.whenUnreachable = { _ in
			KurozoraDelegate.shared.showOfflineView(for: nil)
		}

		// If the network is unreachable show the offline page
		KNetworkManager.isUnreachable { [weak self] _ in
			guard let self = self else { return }
			self.isUnreachable = true
		}

		// Check network availability
		if self.isUnreachable {
			KurozoraDelegate.shared.showOfflineView(for: self.window)
			return
		}

		// Initiate app
		self.window?.rootViewController = SplashscreenViewController()
		KurozoraDelegate.shared.initiateApp(window: self.window)

		// Configure window or resotre previous activity.
		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			if !configure(window: self.window, with: userActivity) {
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
		print("----- Scene entered background.")
		KurozoraDelegate.shared.userShouldAuthenticate()
//		WorkflowController.shared.scheduleNotification("Sessionne", body: "Gol gara signed in from saboon.")
		authenticationCount = 0
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		print("----- Scene will enter foreground.")
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
		print("----- Scene became active.")
		if self.authenticationCount < 1 {
			if Date.uptime() > KurozoraDelegate.shared.authenticationInterval, KurozoraDelegate.shared.authenticationEnabled {
				DispatchQueue.main.async {
					KurozoraDelegate.shared.prepareForAuthentication()
				}
			}
		}

		self.authenticationCount += 1

		// Clear notifications
		UIApplication.shared.applicationIconBadgeNumber = 0
	}

	// MARK: - Functions
	/// Configures the scene according to the passed activity.
	///
	/// - Parameter window: The backdrop for your app’s user interface and the object that dispatches events to your views.
	/// - Parameter activity: A representation of the state of your app at a moment in time.
    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if activity.title == "OpenShowDetail" {
			if let parameters = activity.userInfo as? [String: String] {
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

	static func createTwoColumnSplitViewController() -> UISplitViewController {
		let navigationController = KNavigationController(rootViewController: SidebarViewController())
		let tabBarController = KTabBarController()
		let splitViewController = UISplitViewController(style: .doubleColumn)
		splitViewController.preferredDisplayMode = .oneBesideSecondary
		#if targetEnvironment(macCatalyst)
		splitViewController.displayModeButtonVisibility = .never
		splitViewController.minimumPrimaryColumnWidth = 220.0
		splitViewController.maximumPrimaryColumnWidth = 220.0
		#endif
		splitViewController.setViewController(navigationController, for: .primary)
		splitViewController.setViewController(tabBarController, for: .compact)
		return splitViewController
	}
}
