//
//  SceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit
#if DEBUG
import FLEX
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var authenticationCount = 0

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		print("----- Scene will connect to session.")
		guard let windowScene = (scene as? UIWindowScene) else { return }

		#if DEBUG && targetEnvironment(macCatalyst)
		if connectionOptions.userActivities.first?.activityType == SceneActivityType.flexDebug.rawValue {
			self.configureFlexDebugScene(windowScene, session: session)
			return
		}
		#endif

		// Initialize UIWindow
		self.window = UIWindow(windowScene: windowScene)
		self.window?.makeKeyAndVisible()

		NotificationCenter.default.addObserver(self, selector: #selector(self.reloadLocalizationForLanguageChange), name: .appLanguageDidChange, object: nil)

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

		// Splash animation plays on cold launch only.
		self.window?.rootViewController = SplashscreenViewController()
		KurozoraDelegate.shared.startInterface(in: self.window, animatesSplash: true)

		FloatingLyricsManager.shared.activate()

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

	/// Re-localizes the visible UI in place after a language change, preserving navigation state.
	@objc private func reloadLocalizationForLanguageChange() {
		self.window?.rootViewController?.reloadLocalizationTree()
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

	#if DEBUG && targetEnvironment(macCatalyst)
	/// Configures the given window scene to host the FLEX globals list.
	///
	/// - Parameters:
	///    - windowScene: The window scene to configure.
	///    - session: The scene session to tag for later reactivation.
	private func configureFlexDebugScene(_ windowScene: UIWindowScene, session: UISceneSession) {
		if session.userInfo == nil {
			session.userInfo = [:]
		}
		session.userInfo?["isFlexDebug"] = true

		self.window = UIWindow(windowScene: windowScene)
		self.window?.rootViewController = self.makeFlexGlobalsRootViewController()
		self.window?.makeKeyAndVisible()

		windowScene.title = "FLEX"
		windowScene.titlebar?.titleVisibility = .visible
		windowScene.titlebar?.toolbar = nil
		windowScene.sizeRestrictions?.minimumSize = CGSize(width: 480, height: 600)
	}

	/// Returns a navigation controller rooted at FLEX's globals view controller.
	///
	/// - Returns: The navigation controller, or a placeholder view controller if `FLEXGlobalsViewController` can't be resolved at runtime.
	private func makeFlexGlobalsRootViewController() -> UIViewController {
		guard let globalsClass = NSClassFromString("FLEXGlobalsViewController") as? UIViewController.Type else {
			let placeholder = UIViewController()
			placeholder.view.backgroundColor = .systemBackground
			return placeholder
		}

		let globalsViewController = globalsClass.init()
		return FLEXNavigationController(rootViewController: globalsViewController)
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
		AuthenticationManager.shared.sceneDidEnterBackground()
		#if DEBUG
		FaceDetectionService.shared.flushOnBackground()
		#endif
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

		if User.isSignedIn {
			NotificationCenter.default.post(name: .KUNDidUpdate, object: nil)
		}

		if User.isSignedIn, let slug = User.current?.attributes.slug {
			Task.detached(priority: .utility) {
				await LibrarySyncEngine.shared.syncAll(forUserSlug: slug)
			}
		}
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		print("----- Scene became active.")
		if self.authenticationCount < 1 {
			AuthenticationManager.shared.sceneDidBecomeActiveIfNeeded()
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
}
