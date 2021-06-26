//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import StoreKit
import Kingfisher
import SwifterSwift

// MARK: - KurozoraKit
let KService = KurozoraKit(debugURL: "https://d6932ed83826.eu.ngrok.io/api/v1/").services(KurozoraDelegate.shared.services)

// MARK: - Kurozora
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	// MARK: - Properties
	var authenticationCount = 0
	var isUnreachable = false
	var menuController: MenuController!

	// MARK: - AppDelegate
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		// Override point for customization after application launch.
		// Init payment queue
		SKPaymentQueue.default().add(KStoreObserver.shared)

		// If the network is unreachable show the offline page
		KNetworkManager.isUnreachable { _ in
			self.isUnreachable = true
		}

		// Monitor network availability
		KNetworkManager.shared.reachability.whenUnreachable = { _ in
			KurozoraDelegate.shared.showOfflinePage(for: nil)
		}

		// Max disk cache size
		ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024

		// Check network availability
		if isUnreachable {
			return true
		}

		// Set UNUserNotificationCenterDelegate
		UNUserNotificationCenter.current().delegate = WorkflowController.shared

		// Restore current user session
		NotificationCenter.default.addObserver(self, selector: #selector(updateMenuBuilder(_:)), name: .KUserIsSignedInDidChange, object: nil)
		WorkflowController.shared.restoreCurrentUserSession()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		KurozoraDelegate.shared.userShouldAuthenticate()
		authenticationCount = 0
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		KNetworkManager.isReachable { _ in
			if User.isSignedIn {
				WorkflowController.shared.registerForPushNotifications()
			}
		}

		if UserSettings.automaticDarkTheme {
			KThemeStyle.checkAutomaticSchedule()
		}
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		if authenticationCount < 1 {
			if Date.uptime() > KurozoraDelegate.shared.authenticationInterval, KurozoraDelegate.shared.authenticationEnabled {
				KurozoraDelegate.shared.prepareForAuthentication()
			}
		}

		authenticationCount += 1

		// Clear notifications
		application.applicationIconBadgeNumber = 0
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		SKPaymentQueue.default().remove(KStoreObserver.shared)
	}
}

// MARK: - UIScene
extension AppDelegate {
	// Here we tell iOS what scene configuration to use
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		connectingSceneSession.userInfo?["activity"] = options.userActivities.first?.activityType

		// Based on the name of the configuration iOS will initialize the correct SceneDelegate
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
	}
}

// MARK: - Continuity
extension AppDelegate {
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		if userActivity.activityType == "OpenAnimeIntent", let parameters = userActivity.userInfo as? [String: Int] {
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

		if User.isSignedIn {
			guard let sessionID = User.current?.relationships?.sessions?.data.first?.id else { return }
			KService.updateSession(sessionID, withToken: apnDeviceToken) { _ in
			}
		}
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		#if DEBUG
		userInfo.forEach({ print("\($0.key): \($0.value)") })
		#endif
	}
}

// MARK: - Notification Handlers
extension AppDelegate {
	/**
		Used to update the menu builder.

		- Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	*/
	@objc func updateMenuBuilder(_ notification: NSNotification) {
		UIMenuSystem.main.setNeedsRebuild()
	}
}

// MARK: - Menu Actions
extension AppDelegate {
	/// Used to update your content.
	@objc func handleRefreshControl() {	}

	/// User chose "Preferences..." from the Application menu.
	@objc func handlePreferences(_ sender: AnyObject) {
		if let settingsSplitViewController = R.storyboard.settings.instantiateInitialViewController() {
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			UIApplication.topViewController?.present(settingsSplitViewController, animated: true)
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
	@objc func handleUsername(_ sender: AnyObject) { }

	/// User chose "Email" from the Account menu.
	@objc func handleEmail(_ sender: AnyObject) { }

	/// User chose "Sign Out" from the Account menu.
	@objc func handleSignIn(_ sender: AnyObject) {
		WorkflowController.shared.presentSignInView()
	}

	/// User chose "Sign Out" from the Account menu.
	@objc func handleSignOut(_ sender: AnyObject) {
		WorkflowController.shared.signOut()
	}

	/// User chose "Upgrade to Pro..." from the Account menu.
	@objc func handleUpgradeToPro(_ sender: AnyObject) {
		let topViewController = UIApplication.topViewController
		if topViewController?.navigationController != nil {
			if let subscriptionTableViewController = R.storyboard.purchase.subscriptionTableViewController() {
				subscriptionTableViewController.navigationItem.leftBarButtonItem = nil
				topViewController?.show(subscriptionTableViewController, sender: nil)
			}
		} else {
			if let subscriptionTableViewController = R.storyboard.purchase.instantiateInitialViewController() {
				topViewController?.present(subscriptionTableViewController, animated: true)
			}
		}
	}

	/// User chose "Subscribe to Reminders..." from the Account menu.
	@objc func handleSubscribeToReminders(_ sender: AnyObject) {
		WorkflowController.shared.subscribeToReminders()
	}

	/// User chose "Redeem" from the Account menu.
	@objc func handleRedeem(_ sender: AnyObject) {
		if let redeemTableViewController = R.storyboard.redeem.redeemTableViewController() {
			redeemTableViewController.navigationItem.leftBarButtonItem = nil
			UIApplication.topViewController?.show(redeemTableViewController, sender: nil)
		}
	}

	/// User chose "Favorite Shows" from the Account menu.
	@objc func handleFavoriteShows(_ sender: AnyObject) {
		if let favoriteShowsCollectionViewController = R.storyboard.favorites.favoriteShowsCollectionViewController() {
			UIApplication.topViewController?.show(favoriteShowsCollectionViewController, sender: nil)
		}
	}
}

// MARK: - Menu
extension AppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		menuController = MenuController(with: builder)
	}
}
