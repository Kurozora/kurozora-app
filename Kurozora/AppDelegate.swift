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
#if DEBUG
import FLEX
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

		// Larger cache size for the now-cacheable catalog detail responses.
		URLCache.shared.memoryCapacity = 50 * 1024 * 1024
		URLCache.shared.diskCapacity = 200 * 1024 * 1024

		// Override point for customization after application launch.
		Store.shared.initialize()

		// Configure keyboard
		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = true
		IQKeyboardManager.shared.resignOnTouchOutside = true
		#endif
		// Set UNUserNotificationCenterDelegate
		UNUserNotificationCenter.current().delegate = WorkflowController.shared

		// Activate WatchConnectivity
		WatchSessionManager.shared.activate()

		// Observer notifications
		NotificationCenter.default.addObserver(self, selector: #selector(updateMenuBuilder(_:)), name: .KUserIsSignedInDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleSignInDidChangeForLibrarySync), name: .KUserIsSignedInDidChange, object: nil)

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
		if connectingSceneSession.userInfo == nil {
			connectingSceneSession.userInfo = [:]
		}
		connectingSceneSession.userInfo?["activity"] = options.userActivities.first?.activityType

		// Restore MiniPlayer activity.
		if #available(iOS 17.0, macCatalyst 17.0, *) {
			let isMiniPlayerActivity = options.userActivities.contains { $0.activityType == SceneActivityType.miniPlayer.rawValue }

			if isMiniPlayerActivity || connectingSceneSession.configuration.name == "MiniPlayer Configuration" {
				let configuration = UISceneConfiguration(name: "MiniPlayer Configuration", sessionRole: connectingSceneSession.role)
				configuration.delegateClass = MiniPlayerSceneDelegate.self
				return configuration
			}
		}

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
			let showDetailsCollectionViewController = ShowDetailsCollectionViewController()(with: kurozoraID)
			UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
		case .openLiterature:
			let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController()(with: kurozoraID)
			UIApplication.topViewController?.show(literatureDetailsCollectionViewController, sender: nil)
		case .openGame:
			let gameDetailsCollectionViewController = GameDetailsCollectionViewController()(with: kurozoraID)
			UIApplication.topViewController?.show(gameDetailsCollectionViewController, sender: nil)
		case .openUser:
			let profileTableViewController = ProfileTableViewController()(with: kurozoraID)
			UIApplication.topViewController?.show(profileTableViewController, sender: nil)
		}

		return true
	}
}

// MARK: - Library Sync
extension AppDelegate {
	/// Triggers a library sync when the signed-in state flips to signed-in.
	@objc func handleSignInDidChangeForLibrarySync() {
		guard User.isSignedIn, let slug = User.current?.attributes.slug else { return }
		Task.detached(priority: .utility) {
			await LibrarySyncEngine.shared.syncAll(forUserSlug: slug)
		}
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
				_ = try await KService.updateAccessToken(withAPNToken: apnDeviceToken)
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
		let mainScenes = UIApplication.shared.connectedScenes.filter { !$0.session.isAuxiliaryScene }

		if mainScenes.isEmpty {
			UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
		}
	}

	/// The session of the open MiniPlayer scene.
	var miniPlayerSession: UISceneSession? {
		return UIApplication.shared.openSessions.first { session in
			session.userInfo?["isMiniPlayer"] as? Bool == true
		}
	}

	/// User chose "MiniPlayer" from the Window menu.
	@objc func handleMiniPlayer(_ sender: AnyObject) {
		guard #available(iOS 17.0, macCatalyst 17.0, *) else { return }

		if let existingSession = self.miniPlayerSession {
			UIApplication.shared.requestSceneSessionDestruction(existingSession, options: nil)
		} else {
			self.openMiniPlayer()
		}
	}

	/// Opens the MiniPlayer.
	func openMiniPlayer() {
		guard #available(iOS 17.0, macCatalyst 17.0, *) else { return }

		if let existingSession = self.miniPlayerSession {
			UIApplication.shared.requestSceneSessionActivation(existingSession, userActivity: nil, options: nil)
			return
		}

		let miniPlayerActivity = NSUserActivity(activityType: .miniPlayer)
		UIApplication.shared.requestSceneSessionActivation(nil, userActivity: miniPlayerActivity, options: nil)
	}

	/// Used to update your content.
	@objc func handleRefreshControl() {}

	/// User chose "Settings…" from the Application menu.
	@objc func handleSettings(_ sender: AnyObject) {
		guard UIApplication.topViewController as? SubSettingsViewController == nil else { return }

		if #available(iOS 18.0, macCatalyst 18.0, *) {
			#if targetEnvironment(macCatalyst)
			guard let tabBarController = UIApplication.topViewController?.tabBarController as? KTabBarController else { return }
			tabBarController.presentSettingsViewController()
			return
			#endif
		}

		let settingsSplitViewController = SettingsSplitViewController()
		settingsSplitViewController.modalPresentationStyle = .fullScreen
		UIApplication.topViewController?.splitViewController?.present(settingsSplitViewController, animated: true)
	}

	/// User chose "Back" from the navigation menu.
	@objc func handleNavigateBack(_ sender: AnyObject) {
		self.contentNavigationController?.navigateBack()
	}

	/// User chose "Forward" from the navigation menu.
	@objc func handleNavigateForward(_ sender: AnyObject) {
		self.contentNavigationController?.navigateForward()
	}

	/// The navigation controller holding the content, which on a wide layout is the split view's secondary column.
	private var contentNavigationController: KNavigationController? {
		return UIApplication.topViewController?.navigationController as? KNavigationController
	}

	/// User chose "Search" from the Application menu.
	@objc func handleSearch(_ sender: AnyObject) {
		if #available(iOS 18.0, macCatalyst 18.0, *) {
			let tabBarController = UIApplication.topViewController?.tabBarController as? KTabBarController
			tabBarController?.selectTab(.search)
		} else {
			let splitViewController = UIApplication.topViewController?.splitViewController
			let navigationController = splitViewController?.viewController(for: .primary) as? KNavigationController
			let sidebarViewController = navigationController?.topViewController as? SidebarViewController
			sidebarViewController?.kSearchController.searchBar.searchTextField.becomeFirstResponder()
		}
	}

	/// User chose the "View My Account…" from the account menu.
	@objc func handleViewMyAccount(_ sender: AnyObject) {
		let settingsSplitViewController = SettingsSplitViewController()
		settingsSplitViewController.modalPresentationStyle = .fullScreen
		if let settingsTableViewController = settingsSplitViewController.navigationController?.visibleViewController as? SettingsTableViewController {
			settingsTableViewController.showDetailViewController(.accountSegue, sender: nil)
		}
		UIApplication.topViewController?.present(settingsSplitViewController, animated: true)
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

	/// User chose "Upgrade to Kurozora+…" from the Account menu.
	@objc func handleUpgradeToKurozoraPlus(_ sender: AnyObject) {
		let subscriptionCollectionViewController = SubscriptionCollectionViewController()
		let kNavigationController = KNavigationController(rootViewController: subscriptionCollectionViewController)
		kNavigationController.navigationItem.leftBarButtonItem = nil
		UIApplication.topViewController?.show(kNavigationController, sender: nil)
	}

	/// User chose "Subscribe to Reminders…" from the Account menu.
	@objc func handleSubscribeToReminders(_ sender: AnyObject) {
		Task { @MainActor in
			let topViewController = UIApplication.topViewController
			guard await WorkflowController.shared.isSubscribed(on: topViewController) else { return }

			let settingsSplitViewController = SettingsSplitViewController()
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			if let settingsTableViewController = settingsSplitViewController.navigationController?.visibleViewController as? SettingsTableViewController {
				settingsTableViewController.showDetailViewController(.reminderSubscriptionSegue, sender: nil)
			}
			UIApplication.topViewController?.present(settingsSplitViewController, animated: true)
		}
	}

	/// User chose "Redeem" from the Account menu.
	@objc func handleRedeem(_ sender: AnyObject) {
		let redeemTableViewController = RedeemTableViewController()
		let kNavigationController = KNavigationController(rootViewController: redeemTableViewController)
		kNavigationController.navigationItem.leftBarButtonItem = nil
		UIApplication.topViewController?.show(kNavigationController, sender: nil)
	}

	/// User chose "Favorites" from the Account menu.
	@objc func handleFavorites(_ sender: AnyObject) {
		Task {
			let signedIn = await WorkflowController.shared.isSignedIn()
			guard signedIn else { return }

			let favoritesCollectionViewController = FavoritesCollectionViewController()
			UIApplication.topViewController?.show(favoritesCollectionViewController, sender: nil)
		}
	}

	#if DEBUG
	/// User chose "Show FLEX Menu" from the Debug menu.
	@objc func handleShowFlex(_ sender: AnyObject) {
		#if targetEnvironment(macCatalyst)
		let existingSession = UIApplication.shared.openSessions.first { session in
			session.userInfo?["isFlexDebug"] as? Bool == true
		}

		if let existingSession = existingSession {
			UIApplication.shared.requestSceneSessionActivation(existingSession, userActivity: nil, options: nil)
		} else {
			let activity = NSUserActivity(activityType: .flexDebug)
			UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil)
		}
		#else
		if FLEXManager.shared.isHidden {
			FLEXManager.shared.showExplorer()
		} else {
			FLEXManager.shared.hideExplorer()
		}
		#endif
	}

	/// User chose "Toggle FLEX Overlay" from the Debug menu.
	@objc func handleToggleFlexOverlay(_ sender: AnyObject) {
		guard FLEXManager.shared.isHidden else {
			FLEXManager.shared.hideExplorer()
			return
		}

		#if targetEnvironment(macCatalyst)
		let mainScene = UIApplication.shared.connectedScenes.first { scene in
			scene.session.userInfo?["isFlexDebug"] as? Bool != true
		} as? UIWindowScene

		if let mainScene = mainScene {
			FLEXManager.shared.showExplorer(from: mainScene)
		} else {
			FLEXManager.shared.showExplorer()
		}
		#else
		FLEXManager.shared.showExplorer()
		#endif
	}
	#endif
}

// MARK: - Menu
extension AppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		self.menuController = MenuController(with: builder)
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		switch action {
		case #selector(self.handleNavigateBack(_:)):
			return (self.contentNavigationController?.viewControllers.count ?? 0) > 1
		case #selector(self.handleNavigateForward(_:)):
			return self.contentNavigationController?.forwardNavigationCoordinator.canNavigateForward ?? false
		case #selector(self.handleMiniPlayer(_:)):
			return UIApplication.shared.supportsMultipleScenes
		default:
			return super.canPerformAction(action, withSender: sender)
		}
	}
}
