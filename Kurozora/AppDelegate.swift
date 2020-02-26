//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import Kingfisher
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	// MARK: - Properties
	var window: UIWindow?
	var authenticationCount = 0
	var isUnreachable = false

	// MARK: - AppDelegate
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		// Override point for customization after application launch.
		// Initialize theme
		KThemeStyle.initAppTheme()

		// Initialize UIWindow
		window = UIWindow()
		window?.makeKeyAndVisible()

		// If the network is unreachable show the offline page
		KNetworkManager.isUnreachable { _ in
			self.isUnreachable = true
		}

		// Monitor network availability
		KNetworkManager.shared.reachability.whenUnreachable = { _ in
			Kurozora.shared.showOfflinePage(for: nil)
		}

		// Max disk cache size
		ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024

		// Global app tint color
		self.window?.theme_tintColor = KThemePicker.tintColor.rawValue

		// Init payment queue
		SKPaymentQueue.default().add(KStoreObserver.shared)

		// Check network availability
		if isUnreachable {
			return true
		}

		// Prepare home view
		if #available(iOS 13.0, macCatalyst 13.0, *) {
		} else {
			let customTabBar = KTabBarController()
			self.window?.rootViewController = customTabBar

			// Check if user should authenticate
			Kurozora.shared.userHasToAuthenticate()
		}

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		Kurozora.shared.userShouldAuthenticate()
		authenticationCount = 0
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		KNetworkManager.isReachable { _ in
			if User.isSignedIn {
				KService.shared.validateSession(withSuccess: { _ in
				})
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
			if Date.uptime() > Kurozora.shared.authenticationInterval, Kurozora.shared.authenticationEnabled {
				Kurozora.shared.prepareForAuthentication()
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
@available(iOS 13.0, macCatalyst 13.0, *)
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
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		Kurozora.shared.schemeHandler(app, open: url, options: options)
		return true
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		if userActivity.activityType == "OpenAnimeIntent", let parameters = userActivity.userInfo as? [String: Int] {
			let showID = parameters["showID"]

			if let showDetailCollectionViewController = R.storyboard.showDetails.showDetailCollectionViewController() {
				showDetailCollectionViewController.showID = showID
				UIApplication.topViewController?.show(showDetailCollectionViewController, sender: nil)
			}
		}

		return true
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		Kurozora.shared.shortcutHandler(application, performActionFor: shortcutItem)
	}
}

// MARK: - Push Notifications
extension AppDelegate {
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
		let apnDeviceToken = tokenParts.joined()

		if User.isSignedIn {
			KService.shared.updateSession(withToken: apnDeviceToken) { _ in
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
