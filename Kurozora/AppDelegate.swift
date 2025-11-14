//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit
#if !targetEnvironment(macCatalyst)
import IQKeyboardManagerSwift
#endif

// MARK: - Kurozora
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	// MARK: - Properties
	var isUnreachable = false
	var menuController: MenuController!

	// MARK: - AppDelegate
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		print("----- UIApplication finished launching.")
		// Override point for customization after application launch.
		Store.shared.initialize()

		// Configure keyboard
		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = true
		IQKeyboardManager.shared.resignOnTouchOutside = true
		#endif
		// Set UNUserNotificationCenterDelegate
		UNUserNotificationCenter.current().delegate = WorkflowController.shared

		// Observer notifications
		NotificationCenter.default.addObserver(self, selector: #selector(updateMenuBuilder(_:)), name: .KUserIsSignedInDidChange, object: nil)

		return true
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		print("----- UIApplication will terminate.")
		Store.shared.updateListenerTask?.cancel()
	}
}

// MARK: - UIScene
extension AppDelegate {
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		print("----- UIApplication connecting to scene session.")
		connectingSceneSession.userInfo?["activity"] = options.userActivities.first?.activityType

		// Based on the name of the configuration iOS will initialize the correct SceneDelegate
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		print("----- UIApplication discarded scene session.")
	}
}

// MARK: - Continuity
extension AppDelegate {
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		guard
			let activityType = ActivityType(rawValue: userActivity.activityType),
			let kurozoraID = try? userActivity.typedPayload(KurozoraItemID.self)
		else { return false }

		switch activityType {
		case .openShow:
			let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: kurozoraID)
			UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
		case .openLiterature:
			let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController.`init`(with: kurozoraID)
			UIApplication.topViewController?.show(literatureDetailsCollectionViewController, sender: nil)
		case .openGame:
			let gameDetailsCollectionViewController = GameDetailsCollectionViewController.`init`(with: kurozoraID)
			UIApplication.topViewController?.show(gameDetailsCollectionViewController, sender: nil)
		case .openUser:
			let profileTableViewController = ProfileTableViewController.`init`(with: kurozoraID)
			UIApplication.topViewController?.show(profileTableViewController, sender: nil)
		}

		return true
	}
}

// MARK: - Push Notifications
extension AppDelegate {
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
		let apnDeviceToken = tokenParts.joined()

		print("----- did register notification with device.", tokenParts, apnDeviceToken)

		if User.isSignedIn {
			Task {
				_ = try await KService.updateAccessToken(withAPNToken: apnDeviceToken).value
			}
		}
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("----- did fail to register notification with device.", error)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		print("----- did receive notification.", userInfo)

		#if DEBUG
		userInfo.forEach { print("\($0.key): \($0.value)") }
		#endif
	}
}

// MARK: - Notification Handlers
extension AppDelegate {
	/// Used to update the menu builder.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updateMenuBuilder(_ notification: NSNotification) {
		UIMenuSystem.main.setNeedsRebuild()
	}
}

// MARK: - Menu Actions
extension AppDelegate {
	/// Used to update your content.
	@objc func handleNewScene() {
		if UIApplication.shared.connectedScenes.count == 0 {
			UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
		}
	}

	/// Used to update your content.
	@objc func handleRefreshControl() {}

	/// User chose "Settings..." from the Application menu.
	@objc func handleSettings(_ sender: AnyObject) {
		guard UIApplication.topViewController as? SubSettingsViewController == nil else { return }

		if #available(iOS 18.0, macCatalyst 18.0, *) {
			#if targetEnvironment(macCatalyst)
			guard let tabBarController = UIApplication.topViewController?.tabBarController as? KTabBarController else { return }
			tabBarController.presentSettingsViewController()
			return
			#endif
		}

		if let settingsSplitViewController = R.storyboard.settings.instantiateInitialViewController() {
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			UIApplication.topViewController?.splitViewController?.present(settingsSplitViewController, animated: true)
		}
	}

	/// User chose "Search" from the Application menu.
	@objc func handleSearch(_ sender: AnyObject) {
		if #available(iOS 18.0, macCatalyst 18.0, *) {
			let tabBarController = UIApplication.topViewController?.tabBarController as? KTabBarController
			tabBarController?.selectedTab = TabBarItem.search.tab
		} else {
			let splitViewController = UIApplication.topViewController?.splitViewController
			let navigationController = splitViewController?.viewController(for: .primary) as? KNavigationController
			let sidebarViewController = navigationController?.topViewController as? SidebarViewController
			sidebarViewController?.kSearchController.searchBar.searchTextField.becomeFirstResponder()
		}
	}

	/// User chose the "View My Account..." from the account menu.
	@objc func handleViewMyAccount(_ sender: AnyObject) {
		if let settingsSplitViewController = R.storyboard.settings.instantiateInitialViewController() {
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			if let settingsTableViewController = (settingsSplitViewController.viewControllers.first as? KNavigationController)?.visibleViewController as? SettingsTableViewController {
				settingsTableViewController.performSegue(withIdentifier: R.segue.settingsTableViewController.accountSegue.identifier, sender: nil)
			}
			UIApplication.topViewController?.present(settingsSplitViewController, animated: true)
		}
	}

	/// User chose "Username" from the Account menu.
	@objc func handleUsername(_ sender: AnyObject) {}

	/// User chose "Email" from the Account menu.
	@objc func handleEmail(_ sender: AnyObject) {}

	/// User chose "Sign Out" from the Account menu.
	@objc func handleSignIn(_ sender: AnyObject) {
		WorkflowController.shared.presentSignInView()
	}

	/// User chose "Sign Out" from the Account menu.
	@objc func handleSignOut(_ sender: AnyObject) {
		Task {
			await WorkflowController.shared.signOut()
		}
	}

	/// User chose "Upgrade to Kurozora+..." from the Account menu.
	@objc func handleUpgradeToKurozoraPlus(_ sender: AnyObject) {
		if let subscriptionKNavigationController = R.storyboard.purchase.subscriptionKNavigationController() {
			subscriptionKNavigationController.navigationItem.leftBarButtonItem = nil
			UIApplication.topViewController?.show(subscriptionKNavigationController, sender: nil)
		}
	}

	/// User chose "Subscribe to Reminders..." from the Account menu.
	@objc func handleSubscribeToReminders(_ sender: AnyObject) {
		Task {
			await WorkflowController.shared.subscribeToReminders()
		}
	}

	/// User chose "Redeem" from the Account menu.
	@objc func handleRedeem(_ sender: AnyObject) {
		if let redeemKNavigationController = R.storyboard.redeem.redeemKNavigationController() {
			redeemKNavigationController.navigationItem.leftBarButtonItem = nil
			UIApplication.topViewController?.show(redeemKNavigationController, sender: nil)
		}
	}

	/// User chose "Favorites" from the Account menu.
	@objc func handleFavorites(_ sender: AnyObject) {
		Task {
			let signedIn = await WorkflowController.shared.isSignedIn()
			guard signedIn else { return }

			if let favoritesCollectionViewController = R.storyboard.favorites.favoritesCollectionViewController() {
				UIApplication.topViewController?.show(favoritesCollectionViewController, sender: nil)
			}
		}
	}
}

// MARK: - Menu
extension AppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		self.menuController = MenuController(with: builder)
	}
}
