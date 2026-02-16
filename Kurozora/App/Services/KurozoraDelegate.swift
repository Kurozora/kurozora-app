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

	func preInitiateApp(window: UIWindow?) async -> Bool {
		// Show warning view if necessary
		if await KurozoraDelegate.shared.showWarningView(for: window) {
			return false
		}

		// Get settings to enable extra functionality
		await WorkflowController.shared.getSettings()

		// Set YouTube API Key
		if let youtubeAPIKey = KSettings?.youtubeAPIKey {
			XCDYouTubeClient.setInnertubeApiKey(youtubeAPIKey)
		}

		// Restore current user session
		await WorkflowController.shared.restoreCurrentUserSession()

		// Done pre-init
		return true
	}

	func initiateApp(window: UIWindow?) {
		Task {
			if await !KurozoraDelegate.shared.preInitiateApp(window: window) {
				return
			}

			// Register Home Screen shortcut items
			await self.registerHomeScreenShortcutItems()

			// Play chime
			if UserSettings.startupSoundAllowed {
				Chime.shared.play()
			}

			// Initialize split view controller
			let rootViewController: UIViewController

			if #available(iOS 18.0, macCatalyst 18.0, *) {
				rootViewController = await KTabBarController()
			} else {
				rootViewController = await SceneDelegate.createTwoColumnSplitViewController()
			}

			DispatchQueue.main.async {
				if let splashViewController = window?.rootViewController as? SplashscreenViewController {
					splashViewController.animateLogo { _ in
						window?.rootViewController = rootViewController
						// Check if user should authenticate
						AuthenticationManager.shared.authenticateIfRequired()
					}
				} else {
					window?.rootViewController = rootViewController
					// Check if user should authenticate
					AuthenticationManager.shared.authenticateIfRequired()
				}
			}
		}
	}

	// MARK: - Functions
	/// Dismiss the current view controller and show the main view controller.
	///
	/// - Parameters:
	///    - window: The window on which the offline view will be shown.
	///    - viewController: The view controller that should be dismissed.
	func showMainPage(for window: UIWindow?, viewController: UIViewController) {
		if let warningViewController = window?.rootViewController as? WarningViewController, warningViewController.router?.dataStore?.warningType == .noSignal {
			// Initialize app
			KurozoraDelegate.shared.initiateApp(window: window)
		} else if let warningViewController = viewController as? WarningViewController, warningViewController.router?.dataStore?.warningType == .noSignal {
			viewController.dismiss(animated: true, completion: nil)
		}

		if User.isSignedIn {
			// Check if user should authenticate
			AuthenticationManager.shared.authenticateIfRequired()
		}
	}

	/// Show a warning view if necessary.
	///
	/// - Parameter window: The window on which the warning view will be shown.
	///
	/// - Returns: a boolean indicating whether a warning view was presented.
	@MainActor
	func showWarningView(for window: UIWindow?) async -> Bool {
		guard let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return false }

		do {
			let metaResponse = try await KService.getInfo().value
			let meta = metaResponse.meta
			let topViewController = UIApplication.topViewController
			let warningViewController = WarningViewController()

			if let warningDataStore = warningViewController.router?.dataStore {
				warningDataStore.window = window

				if meta.isMaintenanceModeEnabled {
					warningDataStore.warningType = .maintenance
				} else if meta.minimumAppVersion.compare(currentAppVersion, options: .numeric) == .orderedDescending {
					warningDataStore.warningType = .forceUpdate
				} else {
					return false
				}
			}

			if window != nil {
				window?.rootViewController = warningViewController
			} else {
				warningViewController.modalPresentationStyle = .fullScreen
				topViewController?.present(warningViewController, animated: true)
			}

			return true
		} catch {
			print("-----", error.localizedDescription)
		}

		return false
	}

	/// Show the forced update view when the API version isn't supported.
	///
	/// - Parameter window: The window on which the force update view will be shown.
	func showOfflineView(for window: UIWindow?) {
		let topViewController = UIApplication.topViewController
		let warningViewController = WarningViewController()

		if let warningDataStore = warningViewController.router?.dataStore {
			warningDataStore.window = window
			warningDataStore.warningType = .noSignal
		}

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
