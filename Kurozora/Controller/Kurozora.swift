//
//  Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import ESTabBarController_swift
import IQKeyboardManagerSwift
import Kingfisher
import RevealingSplashView
import LocalAuthentication
import SCLAlertView

class Kurozora: NSObject {
	fileprivate static var success = false
	var authenticationEnabled = false
	var authenticationInterval = 0

	static let shared = Kurozora()

	// MARK: - Functions
	/**
		Dismiss the current view controller and show the main view controller.

		- Parameter window: The window on which the offline view will be shown.
		- Parameter viewController: The view controller that should be dismissed.
	*/
	static func showMainPage(for window: UIWindow?, viewController: UIViewController) {
		if window?.rootViewController is KurozoraReachabilityViewController {
			// Initialize Pusher
			WorkflowController.pusherInit()

			// Max disk cache size
			ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024

			// Global app tint color
			window?.theme_tintColor = KThemePicker.tintColor.rawValue

			// IQKeyoardManager
			IQKeyboardManager.shared.enable = true
			IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
			IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
			IQKeyboardManager.shared.shouldResignOnTouchOutside = true

			// User login status
			if User.username != nil {
				let customTabBar = KTabBarController()
				window?.rootViewController = customTabBar
			} else {
				revealingSplashView.heartAttack = true
				let welcomeViewController = WelcomeViewController.instantiateFromStoryboard()
				window?.rootViewController = welcomeViewController
			}

			// Play splash view animation
			window?.addSubview(revealingSplashView)
			revealingSplashView.playHeartBeatAnimation()
			NotificationCenter.default.addObserver(self.shared, selector: #selector(handleHeartAttackNotification), name: .KHeartAttackShouldHappen, object: nil)
		} else if viewController is KurozoraReachabilityViewController {
			viewController.dismiss(animated: true, completion: nil)
		}
	}

	/**
		Show the offline page when wifi and data is out.

		- Parameter window: The window on which the offline view will be shown.
	*/
	static func showOfflinePage(for window: UIWindow?) {
		if window != nil {
			if let reachabilityViewController = KurozoraReachabilityViewController.instantiateFromStoryboard() as? KurozoraReachabilityViewController {
				reachabilityViewController.window = window
				window?.rootViewController = reachabilityViewController
			}
		} else {
			DispatchQueue.main.async {
				if let reachabilityViewController = KurozoraReachabilityViewController.instantiateFromStoryboard() {
					let topViewController = UIApplication.topViewController
					topViewController?.modalPresentationStyle = .overFullScreen
					topViewController?.present(reachabilityViewController, animated: false, completion: nil)
				}
			}
		}
	}

	/**
		Return a boolean value indicating if the current session is valid.

		- Parameter window: The window on which the login view will be presented in case the session isn't valid.

		- Returns: a boolean value indicating if the current session is valid.
	*/
	static func validateSession(window: UIWindow?) -> Bool {
		Service.shared.validateSession(withSuccess: { (success) in
			if !success {
				if window?.rootViewController as? WelcomeViewController == nil {
					let welcomeViewController = WelcomeViewController.instantiateFromStoryboard()
					window?.rootViewController = welcomeViewController
					self.success = success
				}
			} else {
				self.success = success
			}
		})

		return success
	}

	/**
		Handle the selected app shortcut.

		- Parameter app: The app's centralized point of control and coordination.
		- Parameter shortcutItem: The application's shortcut item.
	*/
	func shortcutHandler(_ app: UIApplication, _ shortcutItem: UIApplicationShortcutItem) {
		if shortcutItem.type == "HomeShortcut" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 0
			}
		} else if shortcutItem.type == "NotificationShortcut" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 3
			}
		} else if shortcutItem.type == "ProfileShortcut" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 4
			}
		}
	}

	/**
		Handle the scheme passed to the app.

		- Parameter app: The app's centralized point of control and coordination.
		- Parameter url: The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
		- Parameter option: A dictionary of URL handling options. For information about the possible keys in this dictionary and how to handle them, see UIApplicationOpenURLOptionsKey. By default, the value of this parameter is an empty dictionary.
	*/
	func schemeHandler(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) {
		let urlScheme = url.host?.removingPercentEncoding

		if urlScheme == "anime" {
			let showID = url.lastPathComponent
			if !showID.isEmpty {
				if let showTabBarController = ShowDetailTabBarController.instantiateFromStoryboard() as? ShowDetailTabBarController {
					showTabBarController.showID = Int(showID)

					UIApplication.topViewController?.present(showTabBarController, animated: true)
				}
			}
		}

		if urlScheme == "profile" || urlScheme == "user" {
			let userID = url.lastPathComponent
			if !userID.isEmpty {
				if let profileViewController = ProfileTableViewController.instantiateFromStoryboard() as? ProfileTableViewController {
					profileViewController.otherUserID = Int(userID)

					let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)

					UIApplication.topViewController?.present(kurozoraNavigationController)
				}
			}
		}

		if urlScheme == "explore" || urlScheme == "home" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 0
			}
		}

		if urlScheme == "library" || urlScheme == "mylibrary" || urlScheme == "my library" || urlScheme == "list" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 1
			}
		}

		if urlScheme == "forum" || urlScheme == "forums" || urlScheme == "forumThread" || urlScheme == "forumsThread" || urlScheme == "thread" {
			let forumThreadID = url.lastPathComponent
			if !forumThreadID.isEmpty {
				if let threadViewController = ThreadTableViewController.instantiateFromStoryboard() as? ThreadTableViewController {
					threadViewController.forumThreadID = Int(forumThreadID)

					UIApplication.topViewController?.present(threadViewController, animated: true)
				}
			} else {
				if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 2
				}
			}
		}

		if urlScheme == "notification" || urlScheme == "notifications" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 3
			}
		}

		if urlScheme == "feed" || urlScheme == "timeline" {
			if let tabBarController = UIApplication.topViewController?.tabBarController as? ESTabBarController {
				tabBarController.selectedIndex = 4
			}
		}
	}

	/// Stop the splash view animation
	@objc func handleHeartAttackNotification() {
		revealingSplashView.heartAttack = true
	}
}

// MARK: - Authentication
extension Kurozora {
	/// Asks the app if the user should authenticate so the app prepares for it.
	func userShouldAuthenticate() {
		if let authenticationEnabledString = try? GlobalVariables().KDefaults.get("authenticationEnabled"), let authenticationEnabled = Bool(authenticationEnabledString) {
			if authenticationEnabled {
				self.authenticationEnabled = authenticationEnabled
				prepareView()
				prepareTimer()
			}
		}
	}

	/// Tells the app that the user has to authenticate so the app prepares for it.
	func userHasToAuthenticate() {
		if let authenticationEnabledString = try? GlobalVariables().KDefaults.get("authenticationEnabled"), let authenticationEnabled = Bool(authenticationEnabledString) {
			if authenticationEnabled {
				prepareForAuthentication()
			}
		}
	}

	/// Prepare the view to prepare the app for authentication.
	func prepareView() {
		let blurEffect = UIBlurEffect(style: .dark)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = UIApplication.shared.keyWindow!.frame
		blurEffectView.tag = 5614325
		UIApplication.shared.keyWindow?.addSubview(blurEffectView)

		if let authenticationViewController = UIApplication.topViewController as? AuthenticationViewController {
			authenticationViewController.dismiss(animated: false, completion: nil)
		}
	}

	/// Prepare timer to prepare the app for authentication.
	func prepareTimer() {
		let requireAuthentication = try? GlobalVariables().KDefaults.get("requireAuthentication")
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
			if let authenticationViewController = AuthenticationViewController.instantiateFromStoryboard() as? AuthenticationViewController {
				UIApplication.topViewController?.present(authenticationViewController, animated: true, completion: nil)
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
		let reasonString = "Welcome back! Please authenticate to continue."

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

		if #available(iOS 11.0, macOS 10.13, *) {
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
		} else {
			switch errorCode {
			case LAError.touchIDLockout.rawValue:
				message = "Too many failed attempts."
			case LAError.touchIDNotAvailable.rawValue:
				message = "TouchID is not available on the device"
			case LAError.touchIDNotEnrolled.rawValue:
				message = "TouchID is not enrolled on the device"
			default:
				message = "Did not find error code on LAError object"
			}
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
