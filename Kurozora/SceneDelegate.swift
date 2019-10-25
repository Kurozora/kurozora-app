//
//  SceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var isUnreachable = false

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		// Initialize UIWindow
		window = UIWindow(windowScene: windowScene)
		window?.makeKeyAndVisible()

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

		// Resotre previoud activity
		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			 if !configure(window: window, with: userActivity) {
				print("Failed to restore from \(userActivity)")
			 }
		}
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		Kurozora.shared.schemeHandler(scene: scene, open: url)
	}

	func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
		KNetworkManager.isReachable { _ in
			if User.isSignedIn {
				_ = Kurozora.validateSession(window: self.window)
			}
		}

        return scene.userActivity
    }

	// MARK: - Functions
    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if activity.title == "OpenShowDetail" {
			if let parameters = activity.userInfo as? [String: Int] {
				let showID = parameters["showID"]
				if let showDetailViewController = ShowDetailViewController.instantiateFromStoryboard() as? ShowDetailViewController {
					showDetailViewController.showID = showID
					if let tabBarController = window?.rootViewController as? KTabBarController {
						tabBarController.present(showDetailViewController)
						return true
					}
				}
            }
        }
        return false
    }
}
