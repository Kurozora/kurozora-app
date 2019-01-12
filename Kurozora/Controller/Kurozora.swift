//
//  Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import IQKeyboardManagerSwift
import Kingfisher
import RevealingSplashView

class Kurozora: NSObject {
	static var success = false
	static let shared = Kurozora()

	static func showMainPage(for window: UIWindow?, viewController: UIViewController) {
		if window?.rootViewController is KurozoraReachabilityViewController {
			// Initialize Pusher
			WorkflowController.pusherInit()

			// Max disk cache size
			ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024

			// Global app tint color
			window?.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)

			// IQKeyoardManager
			IQKeyboardManager.shared.enable = true
			IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
			IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
			IQKeyboardManager.shared.shouldResignOnTouchOutside = true

			// User login status
			if User.username() != nil {
//				authenticated = true
				let customTabBar = KurozoraTabBarController()
				window?.rootViewController = customTabBar
			} else {
				revealingSplashView.heartAttack = true
				let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
				let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as? WelcomeViewController
				window?.rootViewController = vc
			}

			// Play splash view animation
			window?.addSubview(revealingSplashView)
			revealingSplashView.playHeartBeatAnimation()
			NotificationCenter.default.addObserver(self.shared, selector: #selector(handleHeartAttackNotification), name: heartAttackNotification, object: nil)
		} else if viewController is KurozoraReachabilityViewController  {
			viewController.dismiss(animated: true, completion: nil)
		}
	}

	static func showOfflinePage(for window: UIWindow?) {
		if window != nil {
			let storyboard = UIStoryboard(name: "reachability", bundle: nil)
			if let reachabilityViewController = storyboard.instantiateViewController(withIdentifier: "Reachability") as? KurozoraReachabilityViewController {
				reachabilityViewController.window = window
				window?.rootViewController = reachabilityViewController
			}
		} else {
			DispatchQueue.main.async {
				let storyboard = UIStoryboard(name: "reachability", bundle: nil)
				let reachabilityViewController = storyboard.instantiateViewController(withIdentifier: "Reachability")

				let topViewController = UIApplication.topViewController()
				topViewController?.modalPresentationStyle = .overFullScreen
				topViewController?.present(reachabilityViewController, animated: false, completion: nil)
			}
		}
	}

	static func validateSession(window: UIWindow?) -> Bool {
		Service.shared.validateSession(withSuccess: { (success) in
			if !success {
				if window?.rootViewController as? WelcomeViewController == nil {
					let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
					let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
					window?.rootViewController = vc
					self.success = success
				}
			} else {
				self.success = success
			}
		})

		return success
	}

	static func schemeHandler(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
		let urlScheme = url.host?.removingPercentEncoding

		if urlScheme == "anime" {
			let showID = url.lastPathComponent
			if showID != "" {
				let storyboard = UIStoryboard(name: "details", bundle: nil)
				if let showTabBarController = storyboard.instantiateViewController(withIdentifier: "ShowTabBarController") as? ShowTabBarController {
					showTabBarController.showID = Int(showID)

					UIApplication.topViewController()?.present(showTabBarController, animated: true)
				}
			}
		}

		if urlScheme == "profile" || urlScheme == "feed" || urlScheme == "timeline" {
			let userID = url.lastPathComponent
			if userID != "" {
				let storyboard = UIStoryboard(name: "profile", bundle: nil)
				if let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController {
					profileViewController.otherUserID = Int(userID)

					let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: profileViewController)

					UIApplication.topViewController()?.present(kurozoraNavigationController, animated: true)
				}
			} else {
				if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 4
				}
			}
		}

		if urlScheme == "explore" || urlScheme == "home" {
			if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 0
			}
		}

		if urlScheme == "notification" || urlScheme == "notifications" {
			if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 3
			}
		}

		if urlScheme == "forum" || urlScheme == "forums" || urlScheme == "forumThread" || urlScheme == "forumsThread" || urlScheme == "thread" {
			let forumThreadID = url.lastPathComponent
			if forumThreadID != "" {
				let storyboard = UIStoryboard(name: "forums", bundle: nil)
				if let threadViewController = storyboard.instantiateViewController(withIdentifier: "Thread") as? ThreadViewController {
					threadViewController.forumThreadID = Int(forumThreadID)

					UIApplication.topViewController()?.present(threadViewController, animated: true)
				}
			} else {
				if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 2
				}
			}
		}

		if urlScheme == "library" || urlScheme == "mylibrary" || urlScheme == "my library" || urlScheme == "list" {
			if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 1
			}
		}
	}

	// Stop splash view animation
	@objc func handleHeartAttackNotification() {
		revealingSplashView.heartAttack = true
	}
}
