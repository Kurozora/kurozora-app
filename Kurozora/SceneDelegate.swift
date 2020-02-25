//
//  SceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

@available(iOS 13.0, macCatalyst 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var isUnreachable = false

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		// Initialize UIWindow
		window = UIWindow(windowScene: windowScene)
		window?.makeKeyAndVisible()

		#if targetEnvironment(macCatalyst)
		if let titlebar = windowScene.titlebar {
			titlebar.titleVisibility = .hidden
			titlebar.toolbar = nil
		}
		#endif

		// Global app tint color
		self.window?.theme_tintColor = KThemePicker.tintColor.rawValue

		// If the network is unreachable show the offline page
		KNetworkManager.isUnreachable { _ in
			self.isUnreachable = true
		}

		// Check network availability
		if isUnreachable {
			Kurozora.shared.showOfflinePage(for: window)
			return
		}

		// Initialize home view
		let customTabBar = KTabBarController()
		self.window?.rootViewController = customTabBar

		// Check if user should authenticate
		Kurozora.shared.userHasToAuthenticate()

		// Resotre previoud activity
		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			 if !configure(window: window, with: userActivity) {
				print("Failed to restore from \(userActivity)")
			 }
		}
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		Kurozora.shared.schemeHandler(scene, open: url)
	}

	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		Kurozora.shared.shortcutHandler(windowScene, performActionFor: shortcutItem)
	}

//	func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
//		KNetworkManager.isReachable { _ in
//			if User.isSignedIn {
//				_ = Kurozora.validateSession(window: self.window)
//			}
//		}
//
//        return scene.userActivity
//    }

	func sceneDidEnterBackground(_ scene: UIScene) {
		Kurozora.shared.userShouldAuthenticate()
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		KNetworkManager.isReachable { _ in
			if User.isSignedIn {
				KService.shared.validateSession(withSuccess: { (success) in
					#if DEBUG
					print("Session valid:", success)
					#endif
				})
				WorkflowController.shared.registerForPushNotifications()
			}
		}

		if UserSettings.automaticDarkTheme {
			KThemeStyle.checkAutomaticSchedule()
		}
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		if Date.uptime() > Kurozora.shared.authenticationInterval, Kurozora.shared.authenticationEnabled {
			Kurozora.shared.prepareForAuthentication()
		}

		// Clear notifications
		UIApplication.shared.applicationIconBadgeNumber = 0
	}

	// MARK: - Functions
    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if activity.title == "OpenShowDetail" {
			if let parameters = activity.userInfo as? [String: Int] {
				let showID = parameters["showID"]
				if let showDetailCollectionViewController = R.storyboard.showDetails.showDetailCollectionViewController() {
					showDetailCollectionViewController.showID = showID
					if let tabBarController = window?.rootViewController as? KTabBarController {
						tabBarController.present(showDetailCollectionViewController)
						return true
					}
				}
            }
        }
        return false
    }
}
