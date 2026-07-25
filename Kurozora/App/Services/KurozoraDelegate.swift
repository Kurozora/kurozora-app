//
//  KurozoraDelegate.swift
//  KurozoraDelegate
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit
import XCDYouTubeKit

/// A set of methods and properties used to manage shared behaviors for the `Kurozora` app.
///
/// The `KurozoraDelegate` object manages the app’s shared behaviors.
/// Use the `KurozoraDelegate` object to handle the following tasks:
/// - Handle URL schemes supported by the app.
/// - Initializing your app’s central data structures.
/// - Present appropriate views when the devices reachability changes.
/// - Registering for any required services at launch time, such as [KKServices](x-source-tag://KKServices).
///
/// - Tag: Kurozora
final class KurozoraDelegate {
	// MARK: - Properties
	/// Returns the singleton `KurozoraDelegate` instance.
	static let shared: KurozoraDelegate = KurozoraDelegate()

	// MARK: - Initializers
	/// Initializes an instance of `KurozoraDelegate`.
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleSubscriptionStatusDidUpdate(_:)), name: .KSubscriptionStatusDidUpdate, object: nil)
	}

	@objc func handleSubscriptionStatusDidUpdate(_ notification: NSNotification) {
		Task {
			// Restore current user session
			await WorkflowController.shared.restoreCurrentUserSession()
		}
	}

	/// Performs the app's one-time, process-level startup work.
	///
	/// - Returns: `ready` when startup succeeds, or `blocked` when a server-side condition must be resolved first.
	func performProcessBootstrap() async -> BootstrapOutcome {
		// Block startup if the server reports maintenance or a required update
		if let warningType = await self.startupWarning() {
			return .blocked(warningType)
		}

		#if DEBUG
		FaceDetectionService.shared.activate()
		#endif

		// Start real time notification observer.
		NotificationsRealtimeBridge.shared.start()

		// Initialize the local Core Data store
		_ = PersistenceController.shared

		// Migrate UserDefaults to shared App Group suite for widget access
		UserSettings.migrateToSharedSuiteIfNeeded()

		// Restore selected API endpoint
		#if DEBUG
		if let savedEndpoint = UserSettings.apiEndpoint, let endpoint = APIEndpoints.first(where: { $0.baseURL == savedEndpoint.baseURL }) ?? APIEndpoints.first {
            KService.apiEndpoint(endpoint)
		}
		#endif

		// Migrate legacy keychain entries to the new account storage
		AccountManager.shared.migrateIfNeeded()

		// Resolve the selected account
		let accountKey = UserSettings.selectedAccount
		let account = AccountManager.shared.account(forSlug: accountKey)

		if let account = account {
			KService.authenticationKey = account.authenticationToken
		}

		// Get settings and restore the user session concurrently
		async let settings: Void = WorkflowController.shared.getSettings()
		async let sessionRestored = WorkflowController.shared.restoreCurrentUserSession(updateAuthenticationKey: false)
		await settings
		_ = await sessionRestored

		// Set YouTube API Key
		if let youtubeAPIKey = KSettings?.youtubeAPIKey {
			XCDYouTubeClient.setInnertubeApiKey(youtubeAPIKey)
		}

		// Push auth state to Watch if signed in
		if let account = account {
			WatchSessionManager.shared.sendAuthState(slug: accountKey, token: account.authenticationToken)
		}

		// Library sync once per launch
		if User.isSignedIn, let slug = User.current?.attributes.slug {
			Task.detached(priority: .utility) {
				await LibrarySyncEngine.shared.syncAll(forUserSlug: slug)
			}
		}

		// Register Home Screen shortcut items
		await self.registerHomeScreenShortcutItems()

		// Play chime
		if UserSettings.startupSoundAllowed {
			Chime.shared.play()
		}

		return .ready
	}

	/// Determines whether a server-side condition should block startup.
	///
	/// - Returns: The blocking warning, or `nil` when startup may proceed.
	private func startupWarning() async -> WarningType? {
		guard let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
			return nil
		}

		do {
			let meta = try await KService.info().response().meta

			if meta.isMaintenanceModeEnabled {
				return .maintenance
			}

			if meta.minimumAppVersion.compare(currentAppVersion, options: .numeric) == .orderedDescending {
				return .forceUpdate
			}
		} catch {
			print("-----", error.localizedDescription)
		}

		return nil
	}

	/// Runs the process bootstrap if needed and installs the resulting interface in the given window.
	///
	/// The bootstrap runs once per process; later windows reuse the cached outcome and skip the splash animation.
	///
	/// - Parameters:
	///    - window: The window to set up.
	///    - animatesSplash: Whether the splash animation may play. Honored only on cold launch.
	func startInterface(in window: UIWindow?, animatesSplash: Bool) {
		Task { @MainActor in
			let result = await AppBootstrap.shared.run {
				await KurozoraDelegate.shared.performProcessBootstrap()
			}
			self.installInterface(in: window, animatesSplash: animatesSplash && result.isColdLaunch, outcome: result.outcome)
		}
	}

	/// Installs the appropriate interface for the given window based on the bootstrap outcome.
	///
	/// - Parameters:
	///    - window: The window whose root view controller will be set.
	///    - animatesSplash: Whether to play the splash animation before showing the main interface.
	///    - outcome: The result of the process bootstrap.
	@MainActor
	private func installInterface(in window: UIWindow?, animatesSplash: Bool, outcome: BootstrapOutcome) {
		guard let window = window else { return }

		switch outcome {
		case .blocked(let warningType):
			let warningViewController = WarningViewController()
			warningViewController.window = window
			warningViewController.warningType = warningType
			window.rootViewController = warningViewController

		case .ready:
			let rootViewController = self.makeRootViewController()

			if animatesSplash, let splashViewController = window.rootViewController as? SplashscreenViewController {
				splashViewController.animateLogo { _ in
					window.rootViewController = rootViewController
					AuthenticationManager.shared.authenticateIfRequired()
				}
			} else {
				window.rootViewController = rootViewController
				AuthenticationManager.shared.authenticateIfRequired()
			}
		}
	}

	/// Builds the main interface's root view controller for the current platform.
	///
	/// - Returns: A `KTabBarController` on supported systems, or a two-column split view controller otherwise.
	@MainActor
	private func makeRootViewController() -> UIViewController {
		if #available(iOS 18.0, macCatalyst 18.0, *) {
			return KTabBarController()
		}

		return self.makeTwoColumnSplitViewController()
	}

	/// Builds the pre-iOS 18 sidebar and tab bar split view controller.
	///
	/// - Returns: A configured two-column split view controller.
	@MainActor
	private func makeTwoColumnSplitViewController() -> UISplitViewController {
		let navigationController = KNavigationController(rootViewController: SidebarViewController())
		#if targetEnvironment(macCatalyst)
		navigationController.extendedLayoutIncludesOpaqueBars = true
		navigationController.additionalSafeAreaInsets.top = -28 // roughly the titlebar height
		#endif
		navigationController.navigationItem.largeTitleDisplayMode = .never

		let tabBarController = KTabBarController()
		let splitViewController = UISplitViewController(style: .doubleColumn)
		splitViewController.primaryBackgroundStyle = .sidebar
		splitViewController.preferredSplitBehavior = .tile
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

	// MARK: - Functions
	/// Dismiss the current view controller and show the main view controller.
	///
	/// - Parameters:
	///    - window: The window on which the offline view will be shown.
	///    - viewController: The view controller that should be dismissed.
	func showMainPage(for window: UIWindow?, viewController: UIViewController) {
		if let warningViewController = window?.rootViewController as? WarningViewController, warningViewController.warningType == .noSignal {
			// Re-run startup for this window
			KurozoraDelegate.shared.startInterface(in: window, animatesSplash: false)
		} else if let warningViewController = viewController as? WarningViewController, warningViewController.warningType == .noSignal {
			viewController.dismiss(animated: true, completion: nil)
		}

		if User.isSignedIn {
			// Check if user should authenticate
			AuthenticationManager.shared.authenticateIfRequired()
		}
	}

	/// Show the forced update view when the API version isn't supported.
	///
	/// - Parameter window: The window on which the force update view will be shown.
	func showOfflineView(for window: UIWindow?) {
		let topViewController = UIApplication.topViewController
		let warningViewController = WarningViewController()
		warningViewController.window = window
		warningViewController.warningType = .noSignal

		DispatchQueue.main.async {
			if window != nil {
				window?.rootViewController = warningViewController
			} else {
				warningViewController.modalPresentationStyle = .fullScreen
				topViewController?.present(warningViewController, animated: true)
			}
		}
	}
}

// MARK: - Home Screen Shortcut Item
extension KurozoraDelegate {
	/// Register Home Screen shortcut items.
	@MainActor
	func registerHomeScreenShortcutItems() {
		UIApplication.shared.shortcutItems = HomeScreenShortcutItem.allCases.map { $0.shortcutItem }
	}

	/// Handle the selected quick action.
	///
	/// - Parameters:
	///    - windowScene: The window scene object receiving the shortcut item.
	///    - shortcutItem: The action selected by the user. Your app defines the actions that it supports, and the user chooses from among those actions. For information about how to create and configure shortcut items for your app, see [UIApplicationShortcutItem](apple-reference-documentation://hsTvcCjEDQ).
	@MainActor
	func shortcutHandler(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async {
		guard let action = HomeScreenShortcutItem(type: shortcutItem.type) else { return }

		switch action {
		case .search:
			await NavigationManager.shared.schemeHandler(windowScene, open: .search)
		case .library:
			await NavigationManager.shared.schemeHandler(windowScene, open: .library)
		case .profile:
			guard await WorkflowController.shared.isSignedIn() else { return }
			await NavigationManager.shared.schemeHandler(windowScene, open: .profile)
		case .notifications:
			await NavigationManager.shared.schemeHandler(windowScene, open: .notifications)
		}
	}
}
