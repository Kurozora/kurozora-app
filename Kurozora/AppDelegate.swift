//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import IQKeyboardManagerSwift
import Kingfisher
import SwifterSwift

/// A root object that stores information about a song resource.
typealias KKSong = Song

// MARK: - KurozoraKit
let KService = KurozoraKit().services(KurozoraDelegate.shared.services)
var KSettings: Settings?
var store: Store! = nil

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
		store = Store()

		// Configure kyrboard
		IQKeyboardManager.shared.enable = true
		IQKeyboardManager.shared.resignOnTouchOutside = true

		// Max disk cache size
		ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024

		// Set UNUserNotificationCenterDelegate
		UNUserNotificationCenter.current().delegate = WorkflowController.shared

		// Observer notifications
		NotificationCenter.default.addObserver(self, selector: #selector(updateMenuBuilder(_:)), name: .KUserIsSignedInDidChange, object: nil)

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		print("----- UIApplication will resign active.")
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("----- UIApplication entered background.")
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		print("----- UIApplication will enter foreground.")
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		print("----- UIApplication became active.")
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		print("----- UIApplication will terminate.")
		store.updateListenerTask?.cancel()
	}
}

// MARK: - UIScene
extension AppDelegate {
	// Here we tell iOS what scene configuration to use
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
		if userActivity.activityType == "OpenAnimeIntent", let parameters = userActivity.userInfo as? [String: String] {
			guard let showID = parameters["showID"] else { return false }

			let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
			UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
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
		userInfo.forEach({ print("\($0.key): \($0.value)") })
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
	@objc func handleRefreshControl() { }

	/// User chose "Settings..." from the Application menu.
	@objc func handleSettings(_ sender: AnyObject) {
		if let settingsSplitViewController = R.storyboard.settings.instantiateInitialViewController() {
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			UIApplication.topViewController?.splitViewController?.present(settingsSplitViewController, animated: true)
		}
	}

	/// User chose "Search" from the Application menu.
	@objc func handleSearch(_ sender: AnyObject) {
		let splitViewController = UIApplication.topViewController?.splitViewController
		let navigationController = splitViewController?.viewController(for: .primary) as? KNavigationController
		let sidebarViewController = navigationController?.topViewController as? SidebarViewController
		sidebarViewController?.kSearchController.searchBar.textField?.becomeFirstResponder()
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
	@objc func handleUsername(_ sender: AnyObject) { }

	/// User chose "Email" from the Account menu.
	@objc func handleEmail(_ sender: AnyObject) { }

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
		WorkflowController.shared.subscribeToReminders()
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
		WorkflowController.shared.isSignedIn {
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
