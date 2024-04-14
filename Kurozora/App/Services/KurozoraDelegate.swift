//
//  KurozoraDelegate.swift
//  KurozoraDelegate
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import ESTabBarController_swift
import LocalAuthentication
import XCDYouTubeKit

/// A set of methods and properties used to manage shared behaviors for the `Kurozora` app.
///
/// The `KurozoraDelegate` object manages the app’s shared behaviors.
/// Use the `KurozoraDelegate` object to handle the following tasks:
/// - Ask the user for authentication before using the app.
/// - Handle URL schemes supported by the app.
/// - Initializing your app’s central data structures.
/// - Present aproriate views when the devices reachability changes.
/// - Registering for any required services at launch time, such as [KKServices](x-source-tag://KKServices).
///
/// - Tag: Kurozora
class KurozoraDelegate {
	// MARK: - Properties
	// Authentication
	/// Indicates whether authentication has been enabled by the user.
	var authenticationEnabled: Bool = false

	/// The interval used to determine whether the app should ask the user for authentication.
	var authenticationInterval: Int = 0

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

			// Play chime
			if UserSettings.startupSoundAllowed {
				Chime.shared.play()
			}

			// Initialize split view controller
			let splitViewController = await SceneDelegate.createTwoColumnSplitViewController()

			DispatchQueue.main.async {
				window?.rootViewController = splitViewController
			}

			// Check if user should authenticate
			KurozoraDelegate.shared.userHasToAuthenticate()
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
			KurozoraDelegate.shared.userHasToAuthenticate()
		}
	}

	/// Show a warning view if necessary.
	///
	/// - Parameter window: The window on which the warning view will be shown.
	///
	/// - Returns: a boolean indicating whether a warning view was presented.
	func showWarningView(for window: UIWindow?) async -> Bool {
		guard let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return false }

		do {
			let metaResponse = try await KService.getInfo().value
			let meta = metaResponse.meta
			let topViewController = await UIApplication.topViewController
			let warningViewController = await WarningViewController()

			if let warningDataStore = await warningViewController.router?.dataStore {
				warningDataStore.window = window

				if meta.isMaintenanceModeEnabled {
					warningDataStore.warningType = .maintenance
				} else if meta.minimumAppVersion.compare(currentAppVersion) == .orderedDescending {
					warningDataStore.warningType = .forceUpdate
				} else {
					return false
				}
			}

			DispatchQueue.main.async {
				if window != nil {
					window?.rootViewController = warningViewController
				} else {
					warningViewController.modalPresentationStyle = .fullScreen
					topViewController?.present(warningViewController, animated: true)
				}
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

	/// Routes the scheme with the specified url to an in app resource.
	///
	/// - Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	fileprivate func routeScheme(with url: URL) {
		if url.pathExtension == "xml" {
			WorkflowController.shared.isSignedIn {
				let topViewController = UIApplication.topViewController
				if let libraryImportTableViewController = topViewController as? LibraryImportTableViewController {
					libraryImportTableViewController.selectedFileURL = url
				} else if let kNavigationController = (topViewController as? SettingsSplitViewController)?.viewControllers[1] as? KNavigationController {
					if let libraryImportTableViewController = kNavigationController.topViewController as? LibraryImportTableViewController {
						libraryImportTableViewController.selectedFileURL = url
					} else if let libraryImportTableViewController = R.storyboard.accountSettings.libraryImportTableViewController() {
						libraryImportTableViewController.selectedFileURL = url
						kNavigationController.show(libraryImportTableViewController, sender: nil)
					}
				} else if let libraryImportTableViewController = R.storyboard.accountSettings.libraryImportTableViewController() {
					let closeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: libraryImportTableViewController, action: #selector(libraryImportTableViewController.dismissButtonPressed))
					libraryImportTableViewController.navigationItem.leftBarButtonItem = closeBarButtonItem
					libraryImportTableViewController.selectedFileURL = url
					let kNavigationController = KNavigationController(rootViewController: libraryImportTableViewController)
					topViewController?.show(kNavigationController, sender: nil)
				}
			}
		}

		guard let urlScheme = url.host?.removingPercentEncoding else { return }
		guard let scheme: Scheme = Scheme(rawValue: urlScheme) else { return }
		let parameters: [String: String] = url.queryParameters ?? [:]

		switch scheme {
		case .anime, .show:
			let showID = url.lastPathComponent
			if !showID.isEmpty {
				let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
				UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
			}
		case .profile, .user:
			let lastPathComponent = url.lastPathComponent
			guard let userID = lastPathComponent.isEmpty ? User.current?.id : lastPathComponent else { return }
			let profileTableViewController = ProfileTableViewController.`init`(with: userID)

			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedViewController?.show(profileTableViewController, sender: nil)
			} else {
				UIApplication.topViewController?.show(profileTableViewController, sender: nil)
			}
		case .explore, .home:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = 0
			}
		case .library, .myLibrary, .list:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = 1
			}
		case .feed, .timeline:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = 2
			}
		case .notification, .notifications:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let tabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				tabBarController.selectedIndex = 3
			}
		case .search:
			if UIDevice.isPhone {
				guard let splitViewController = UIApplication.topSplitViewController else { return }
				guard let kTabBarController = splitViewController.viewController(for: .compact) as? KTabBarController else { return }
				guard let kNavigationController = kTabBarController.viewControllers?[safe: 4] as? KNavigationController else { return }
				guard let searchResultsCollectionViewController = kNavigationController.topViewController as? SearchResultsCollectionViewController else { return }

				kTabBarController.selectedIndex = 4
				self.handleSearchDeeplink(
					on: searchResultsCollectionViewController,
					searchController: searchResultsCollectionViewController.kSearchController,
					parameters: parameters
				)
			} else {
				DispatchQueue.main.async {
					guard let splitViewController = UIApplication.topViewController?.splitViewController else { return }
					guard let navigationController = splitViewController.viewController(for: .primary) as? KNavigationController else { return }
					guard let sidebarViewController = navigationController.topViewController as? SidebarViewController else { return }

					self.handleSearchDeeplink(
						on: sidebarViewController.searchResultsCollectionViewController,
						searchController: sidebarViewController.kSearchController,
						parameters: parameters
					)
				}
			}
		}
	}

	/// Handles deeplinking to the search view.
	///
	/// - Parameters:
	///    - viewController: An instance of `SearchResultsCollectionViewController` to deeplink to.
	///    - searchController: An instance of `KSearchController` to perform the search if required.
	///    - parameters: The parameters used for performing the search.
	fileprivate func handleSearchDeeplink(
		on viewController: SearchResultsCollectionViewController,
		searchController: KSearchController,
		parameters: [String: String]
	) {
		let queryString = parameters["q"] ?? ""
		let scopeString = Int(parameters["scope"] ?? "0")
		let typeString = parameters["type"] ?? KKSearchType.shows.rawValue
		let scope: KKSearchScope = if let scopeString = scopeString {
			KKSearchScope(rawValue: scopeString) ?? .kurozora
		} else {
			.kurozora
		}
		let type: KKSearchType = KKSearchType(rawValue: typeString) ?? .shows

		if parameters.isEmpty {
			searchController.searchBar.textField?.becomeFirstResponder()
		} else if !queryString.isEmpty {
			viewController.searachQuery = queryString
			viewController.currentScope = scope
			viewController.currentTypes = [type]
			searchController.searchBar.textField?.text = queryString
			searchController.searchBar.selectedScopeButtonIndex = scope.rawValue

			if viewController.dataSource == nil {
				viewController.isDeepLinked = true
				searchController.searchBar.textField?.resignFirstResponder()
				searchController.searchBar.textField?.resignFirstResponder()
			} else {
				viewController.performSearch(with: queryString, in: scope, for: [type], with: nil, next: nil, resettingResults: true)
			}
		}
	}

	/// Opens a resource specified by a URL.
	///
	/// - Parameters:
	///    - scene: The object that represents one instance of the app's user interface.
	///    - url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	func schemeHandler(_ scene: UIScene, open url: URL) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.routeScheme(with: url)
		}
	}
}

// MARK: - Authentication
extension KurozoraDelegate {
	/// Asks the app if the user should authenticate so the app prepares for it.
	func userShouldAuthenticate() {
		self.authenticationEnabled = UserSettings.authenticationEnabled
		if self.authenticationEnabled {
			prepareView()
			setAuthenticationInterval()
		}
	}

	/// Tells the app that the user has to authenticate so the app prepares for it.
	func userHasToAuthenticate() {
		if UserSettings.authenticationEnabled {
			DispatchQueue.main.async {
				self.prepareForAuthentication()
			}
		}
	}

	/// Prepare the view to prepare the app for authentication.
	func prepareView() {
		if let authenticationViewController = UIApplication.topViewController as? AuthenticationViewController {
			authenticationViewController.dismiss(animated: false, completion: nil)
		}
	}

	/// Sets the authentication interval.
	func setAuthenticationInterval() {
		self.authenticationInterval = Date.uptime() + UserSettings.authenticationInterval.rawValue
	}

	/// Prepare the app for authentication.
	@objc func prepareForAuthentication() {
		let topViewController = UIApplication.topViewController

		// If user should authenticate but the top view controller isn't AuthenticationViewController
		if let isAuthenticationViewController = topViewController?.isKind(of: AuthenticationViewController.self), !isAuthenticationViewController {
			if let authenticationViewController = R.storyboard.authentication.authenticationViewController() {
				topViewController?.present(authenticationViewController, animated: true)
			}
		} else if topViewController == nil {
			if let authenticationViewController = R.storyboard.authentication.authenticationViewController() {
				topViewController?.present(authenticationViewController, animated: true)
			}
		}
	}

	/// Handle the user authentication
	func handleUserAuthentication() {
		guard let viewController = UIApplication.topViewController as? AuthenticationViewController else { return }

		self.localAuthentication(viewController: viewController) { success in
			if success {
				DispatchQueue.main.async {
					viewController.dismiss(animated: true, completion: nil)
				}
			} else {
				viewController.toggleHide()
			}
		}
	}

	/// Start local authentication.
	///
	/// - Parameters:
	///    - viewController: The view controller on which the authentication is taking place.
	///    - successHandler: A closure returning a boolean indicating whether authentication is successful.
	///    - isSuccess: A boolean value indicating whether authentication is successful.
	fileprivate func localAuthentication(viewController: AuthenticationViewController, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let localAuthenticationContext = LAContext()
		var authError: NSError?

		#if targetEnvironment(macCatalyst)
		let reasonString = "authenticate to continue."
		#else
		let reasonString = "Welcome back! Please authenticate to continue."
		#endif

		if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
			localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
				if success {
					// User authenticated successfully.
					successHandler(success)
				} else {
					// User did not authenticate successfully.
					DispatchQueue.main.async {
						guard let error = evaluateError else { return }

						// If user has chosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully.
						switch error._code {
						case LAError.userFallback.rawValue:
							print("fallback chosen")
						case LAError.userCancel.rawValue:
							successHandler(success)
						default: break
						}
					}
				}
			}
		} else {
			guard let error = authError else { return }
			// Show appropriate alert if biometry/TouchID/FaceID is locked out or not enrolled.
			UIApplication.topViewController?.presentAlertController(title: "Error Authenticating", message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
		}
	}

	/// Return a string describing the evaluated Policy Fail Error error code.
	///
	/// - Parameter errorCode: The error code to evaluate.
	///
	/// - Returns: a string describing the evaluated error code.
	fileprivate func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
		var message = ""

		switch errorCode {
		case LAError.biometryNotAvailable.rawValue:
			message = "Authentication could not start because the device does not support biometric authentication."
		case LAError.biometryLockout.rawValue:
			message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
		case LAError.biometryNotEnrolled.rawValue:
			message = "Authentication could not start because the user has not enrolled in biometric authentication."
		default:
			message = "Did not find error code on LAError object"
		}

		return message
	}

	/// Return a string describing the evaluated Authentication Policy error code.
	///
	/// - Parameter errorCode: The error code to evaluate.
	///
	/// - Returns: a string describing the evaluated error code.
	fileprivate func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
		var message = ""

		switch errorCode {
		case LAError.authenticationFailed.rawValue:
			message = "The user failed to provide valid credentials"
		case LAError.appCancel.rawValue:
			message = "Authentication was cancelled by application"
		case LAError.invalidContext.rawValue:
			message = "The context is invalid"
		case LAError.notInteractive.rawValue:
			message = "Not interactive"
		case LAError.passcodeNotSet.rawValue:
			message = "Passcode is not set on the device"
		case LAError.systemCancel.rawValue:
			message = "Authentication was cancelled by the system"
		case LAError.userCancel.rawValue:
			message = "The user did cancel"
		case LAError.userFallback.rawValue:
			message = "The user chose to use the fallback"
		default:
			message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
		}

		return message
	}
}

// MARK: - Quick Actions
extension KurozoraDelegate {
	/// Handle the selected quick action.
	///
	/// - Parameters:
	///    - windowScene: The window scene object receiving the shortcut item.
	///    - shortcutItem: The action selected by the user. Your app defines the actions that it supports, and the user chooses from among those actions. For information about how to create and configure shortcut items for your app, see [UIApplicationShortcutItem](apple-reference-documentation://hsTvcCjEDQ).
	func shortcutHandler(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) {
		switch shortcutItem.type {
		case R.info.uiApplicationShortcutItems.libraryShortcut.uiApplicationShortcutItemType:
			self.schemeHandler(windowScene, open: Scheme.library.urlValue)
		case R.info.uiApplicationShortcutItems.profileShortcut.uiApplicationShortcutItemType:
			WorkflowController.shared.isSignedIn {
				self.schemeHandler(windowScene, open: Scheme.profile.urlValue)
			}
		case R.info.uiApplicationShortcutItems.notificationShortcut.uiApplicationShortcutItemType:
			self.schemeHandler(windowScene, open: Scheme.notifications.urlValue)
		case R.info.uiApplicationShortcutItems.searchShortcut.uiApplicationShortcutItemType:
			self.schemeHandler(windowScene, open: Scheme.search.urlValue)
		default: break
		}
	}
}
