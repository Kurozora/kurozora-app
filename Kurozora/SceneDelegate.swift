//
//  SceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

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
		self.setupNSToolbar()
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

		/// Call `updateAppShortcutParameters` on `ShortcutsProvider` so that the system updates the App Shortcut phrases with any changes to
		/// the app's intent parameters. The app needs to call this function during its launch, in addition to any time the parameter values for
		/// the shortcut phrases change.
		if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
			ShortcutsProvider.updateAppShortcutParameters()
		}

		// Configure window or restore previous activity.
		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			self.configure(scene: self.window?.windowScene, with: userActivity)
		}
	}

	#if targetEnvironment(macCatalyst)
	func setupNSToolbar() {
		let toolbar = NSToolbar()
		toolbar.displayMode = .iconOnly
		self.window?.windowScene?.titlebar?.toolbar = toolbar
		self.window?.windowScene?.titlebar?.titleVisibility = .hidden
		self.window?.windowScene?.sizeRestrictions?.minimumSize = CGSize(width: 1000, height: 432)
	}
	#endif

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }

		Task {
			await NavigationManager.shared.schemeHandler(scene, open: url)
		}
	}

	func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
		self.configure(scene: scene, with: userActivity)
	}

	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
		await KurozoraDelegate.shared.shortcutHandler(windowScene, performActionFor: shortcutItem)
		return true
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		print("----- Scene entered background.")
		KurozoraDelegate.shared.userShouldAuthenticate()
//		WorkflowController.shared.scheduleNotification("Sessionne", body: "Gol gara signed in from saboon.")
		self.authenticationCount = 0
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
	/// - Parameters:
	///    - scene: The object that represents one instance of the app's user interface.
	///    - userActivity: A representation of the state of your app at a moment in time.
	func configure(scene: UIScene?, with userActivity: NSUserActivity) {
		guard
			let activityType = ActivityType(rawValue: userActivity.activityType),
			let kurozoraID = (try? userActivity.typedPayload([String: KurozoraItemID].self))?["id"],
			let scene = scene
		else {
			print("----- Failed to restore from \(userActivity)")
			return
		}

		// Abomination of a URL scheme construction
		guard let url: URL = switch activityType {
		case .openShow:
			URL(string: "kurozora://anime/\(kurozoraID)")
		case .openGame:
			URL(string: "kurozora://game/\(kurozoraID)")
		case .openLiterature:
			URL(string: "kurozora://literature/\(kurozoraID)")
		case .openUser:
			URL(string: "kurozora://profile/\(kurozoraID)")
		} else {
			print("----- Url construction failed for \(userActivity)")
			return
		}

		Task {
			await NavigationManager.shared.schemeHandler(scene, open: url)
		}

		print("----- Succeeded to restore from \(userActivity)")
	}

	static func createTwoColumnSplitViewController() -> UISplitViewController {
		let navigationController = KNavigationController(rootViewController: SidebarViewController())
		#if targetEnvironment(macCatalyst)
		navigationController.extendedLayoutIncludesOpaqueBars = true
		navigationController.additionalSafeAreaInsets.top = -28 // roughly the titlebar height
		#endif
		navigationController.navigationItem.largeTitleDisplayMode = .never

		let tabBarController = KTabBarController()
		let splitViewController = UISplitViewController(style: .doubleColumn)
		splitViewController.primaryBackgroundStyle = .sidebar
		splitViewController.preferredDisplayMode = .oneBesideSecondary
		#if targetEnvironment(macCatalyst)
		splitViewController.extendedLayoutIncludesOpaqueBars = true
		splitViewController.displayModeButtonVisibility = .never
		splitViewController.minimumPrimaryColumnWidth = 220.0
		splitViewController.maximumPrimaryColumnWidth = 220.0
		splitViewController.additionalSafeAreaInsets.top = -28 // roughly the titlebar height
		#endif
		splitViewController.setViewController(navigationController, for: .primary)
		splitViewController.setViewController(tabBarController, for: .compact)
		return splitViewController
	}
}
