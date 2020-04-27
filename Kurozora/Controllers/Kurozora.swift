//
//  Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import ESTabBarController_swift
import KeychainAccess
import LocalAuthentication
import SCLAlertView

/**
	A set of methods and properties used to manage shared behaviors for the `Kurozora` app.

	The `Kurozora` object manages the app’s shared behaviors.
	Use the `Kurozora` object to handle the following tasks:
	- Ask the user for authentication before using the app.
	- Handle URL schemes supported by the app.
	- Initializing your app’s central data structures.
	- Present aproriate views when the devices reachability changes.
	- Registering for any required services at launch time, such as [KKServices](x-source-tag://KKServices).

	- Tag: Kurozora
*/
class Kurozora {
	// MARK: - Properties
	// Authentication
	/// Indicates whether authentication has been enabled by the user.
	var authenticationEnabled: Bool = false

	/// The interval used to determine whether the app should ask the user for authentication.
	var authenticationInterval: Int = 0

	/// Returns the singleton Kurozora instance.
	static let shared: Kurozora = Kurozora()

	// KurozoraKit
	/// The app's identifier prefix.
	private let appIdentifierPrefix: String = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String

	/// The app's base keychain service.
	let keychain: Keychain

	/// KurozoraKit's enabled services
	let services: KKServices

	// MARK: - Initializers
	/// Initializes an instance of `Kurozora` with `Keychain` and `KKService` objects.
	private init() {
		self.keychain = Keychain(service: "Kurozora", accessGroup: "\(self.appIdentifierPrefix)app.kurozora.shared").synchronizable(true).accessibility(.afterFirstUnlock)
		self.services = KKServices(keychain: self.keychain, showAlerts: true)
	}

	// MARK: - Functions
	/**
		Dismiss the current view controller and show the main view controller.

		- Parameter window: The window on which the offline view will be shown.
		- Parameter viewController: The view controller that should be dismissed.
	*/
	func showMainPage(for window: UIWindow?, viewController: UIViewController) {
		if window?.rootViewController is KurozoraReachabilityViewController {
			let customTabBar = KTabBarController()
			window?.rootViewController = customTabBar
		} else if viewController is KurozoraReachabilityViewController {
			viewController.dismiss(animated: true, completion: nil)
		}

		if User.isSignedIn {
			// Check if user should authenticate
			Kurozora.shared.userHasToAuthenticate()
		}
	}

	/**
		Show the offline page when wifi and data is out.

		- Parameter window: The window on which the offline view will be shown.
	*/
	func showOfflinePage(for window: UIWindow?) {
		if window != nil {
			if let reachabilityViewController = R.storyboard.reachability.kurozoraReachabilityViewController() {
				reachabilityViewController.window = window
				window?.rootViewController = reachabilityViewController
			}
		} else {
			DispatchQueue.main.async {
				if let reachabilityViewController = R.storyboard.reachability.kurozoraReachabilityViewController() {
					let topViewController = UIApplication.topViewController
					topViewController?.present(reachabilityViewController)
				}
			}
		}
	}

	/**
		Routes the scheme with the specified url to an in app resource.

		- Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	*/
	fileprivate func routeScheme(with url: URL) {
		if url.pathExtension == "xml" {
			WorkflowController.shared.isSignedIn({
				if let malImportTableViewController = R.storyboard.accountSettings.malImportTableViewController() {
					malImportTableViewController.selectedFileURL = url

					UIApplication.topViewController?.show(malImportTableViewController, sender: nil)
				}
			})
		}

		guard let urlScheme = url.host?.removingPercentEncoding else { return }
		guard let scheme: Scheme = Scheme(rawValue: urlScheme) else { return }

		switch scheme {
		case .anime, .show:
			let showIDString = url.lastPathComponent
			if !showIDString.isEmpty {
				guard let showID = Int(showIDString) else { return }
				if let showDetailCollectionViewController = R.storyboard.showDetails.showDetailCollectionViewController() {
					showDetailCollectionViewController.showID = showID

					UIApplication.topViewController?.show(showDetailCollectionViewController, sender: nil)
				}
			}
		case .profile, .user:
			let userID = url.lastPathComponent
			let isCurrentUser = userID.isEmpty || userID.int == User.current?.session?.id
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 4

				if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
					if isCurrentUser {
						WorkflowController.shared.isSignedIn {
							tabBarController.selectedViewController?.show(profileTableViewController, sender: nil)
						}
					} else {
						profileTableViewController.userID = userID.int
						tabBarController.selectedViewController?.show(profileTableViewController, sender: nil)
					}
				}
			}
		case .explore, .home:
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 0
			}
		case .library, .myLibrary, .list:
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 1
			}
		case .forum, .forums, .forumThread, .forumsThread, .thread:
			let forumThreadIDString = url.lastPathComponent
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 2

				if !forumThreadIDString.isEmpty {
					guard let forumThreadID = forumThreadIDString.int else { return }
					if let threadTableViewController = R.storyboard.forums.threadTableViewController() {
						threadTableViewController.forumThreadID = forumThreadID
						tabBarController.selectedViewController?.show(threadTableViewController, sender: nil)
					}
				}
			}
		case .notification, .notifications:
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 3
			}
		case .feed, .timeline:
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 4
			}
		}
	}

	/**
		Opens a resource specified by a URL.

		- Parameter app: The app's centralized point of control and coordination.
		- Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
		- Parameter option: A dictionary of URL handling options. For information about the possible keys in this dictionary and how to handle them, see UIApplicationOpenURLOptionsKey. By default, the value of this parameter is an empty dictionary.
	*/
	func schemeHandler(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
		routeScheme(with: url)
	}

	/**
		Opens a resource specified by a URL on iOS 13.0+ and macCatalyst 13.0+.

		- Parameter scene: The object that represents one instance of the app's user interface.
		- Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
	*/
	@available(iOS 13.0, macCatalyst 13.0, *)
	func schemeHandler(_ scene: UIScene, open url: URL) {
		routeScheme(with: url)
	}
}

// MARK: - Authentication
extension Kurozora {
	/// Asks the app if the user should authenticate so the app prepares for it.
	func userShouldAuthenticate() {
		if let authenticationEnabledString = try? Kurozora.shared.keychain.get("authenticationEnabled"), let authenticationEnabled = Bool(authenticationEnabledString) {
			if authenticationEnabled {
				self.authenticationEnabled = authenticationEnabled
				prepareView()
				prepareTimer()
			}
		}
	}

	/// Tells the app that the user has to authenticate so the app prepares for it.
	func userHasToAuthenticate() {
		if let authenticationEnabledString = try? Kurozora.shared.keychain.get("authenticationEnabled"), let authenticationEnabled = Bool(authenticationEnabledString) {
			if authenticationEnabled {
				prepareForAuthentication()
			}
		}
	}

	/// Prepare the view to prepare the app for authentication.
	func prepareView() {
		if let authenticationViewController = UIApplication.topViewController as? AuthenticationViewController {
			authenticationViewController.dismiss(animated: false, completion: nil)
		}
	}

	/// Prepare timer to prepare the app for authentication.
	func prepareTimer() {
		let requireAuthentication = try? Kurozora.shared.keychain.get("requireAuthentication")
		var interval = 0

		switch RequireAuthentication.valueFrom(requireAuthentication) {
		case .immediately: break
		case .thirtySeconds:
			interval = 30
		case .oneMinute:
			interval = 60
		case .twoMinutes:
			interval = 120
		case .threeMinutes:
			interval = 180
		case .fourMinutes:
			interval = 240
		case .fiveMinutes:
			interval = 300
		}

		authenticationInterval = Date.uptime() + interval
	}

	/// Prepare the app for authentication.
	@objc func prepareForAuthentication() {
		let topViewController = UIApplication.topViewController

		// If user should authenticate but the top view controller isn't AuthenticationViewController
		if let isAuthenticationViewController = topViewController?.isKind(of: AuthenticationViewController.self), !isAuthenticationViewController {
			if let authenticationViewController = R.storyboard.authentication.authenticationViewController() {
				topViewController?.present(authenticationViewController)
			}
		} else if topViewController == nil {
			if let authenticationViewController = R.storyboard.authentication.authenticationViewController() {
				topViewController?.present(authenticationViewController)
			}
		}
	}

	/// Handle the user authentication
	func handleUserAuthentication() {
		guard let viewController = UIApplication.topViewController as? AuthenticationViewController else { return }

		localAuthentication(viewController: viewController, withSuccess: { success in
			if success {
				DispatchQueue.main.async {
					viewController.dismiss(animated: true, completion: nil)
				}
			} else {
				viewController.toggleHide()
			}
		})
	}

	/**
		Start local authentication.

		- Parameter viewController: The view controller on which the authentication is taking place.
		- Parameter successHandler: A closure returning a boolean indicating whether authentication is successful.
		- Parameter isSuccess: A boolean value indicating whether authentication is successful.
	*/
	fileprivate func localAuthentication(viewController: AuthenticationViewController, withSuccess successHandler:@escaping (_ isSuccess: Bool) -> Void) {
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
			SCLAlertView().showError("Error Authenticating", subTitle: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
		}
	}

	/**
		Return a string describing the evaluated Policy Fail Error error code.

		- Parameter errorCode: The error code to evaluate.

		- Returns: a string describing the evaluated error code.
	*/
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

	/**
		Return a string describing the evaluated Authentication Policy error code.

		- Parameter errorCode: The error code to evaluate.

		- Returns: a string describing the evaluated error code.
	*/
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
extension Kurozora {
	/**
		Performs an action for the specified shortcut item.

		- Parameter shortcutItem: The action selected by the user. Your app defines the actions that it supports, and the user chooses from among those actions. For information about how to create and configure shortcut items for your app, see [UIApplicationShortcutItem](apple-reference-documentation://hsTvcCjEDQ).
	*/
	fileprivate func performAction(for shortcutItem: UIApplicationShortcutItem) {
		if shortcutItem.type == R.info.uiApplicationShortcutItems.homeShortcut._key {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 0
			}
		} else if shortcutItem.type == R.info.uiApplicationShortcutItems.notificationShortcut._key {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 3
			}
		} else if shortcutItem.type == R.info.uiApplicationShortcutItems.profileShortcut._key {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 4
				WorkflowController.shared.isSignedIn {
					if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
						tabBarController.navigationController?.show(profileTableViewController, sender: nil)
					}
				}
			}
		}
	}

	/**
		Handle the selected quick action.

		- Parameter app: The app's centralized point of control and coordination.
		- Parameter shortcutItem: The quick action for which you are providing an implementation in this method.
	*/
	func shortcutHandler(_ app: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem) {
		performAction(for: shortcutItem)
	}

	/**
		Handle the selected quick action on iOS 13.0+ and macCatalyst 13.0+.

		- Parameter windowScene: The window scene object receiving the shortcut item.
		- Parameter shortcutItem: The application's shortcut item.
	*/
	@available(iOS 13.0, *)
	func shortcutHandler(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) {
		performAction(for: shortcutItem)
	}
}
