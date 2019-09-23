//
//  WorkflowController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import PusherSwift
import NotificationBannerSwift
import SCLAlertView
import SwiftyJSON

let optionsWithEndpoint = PusherClientOptions(
	authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder()),
	host: .cluster("eu")
)
let pusher = Pusher(key: "edc954868bb006959e45", options: optionsWithEndpoint)

class WorkflowController {
	// MARK: - Properties
	/// Returns the singleton WorkflowController instance.
	static let shared = WorkflowController()

	// MARK: - Initializations
	private init() {}

	// MARK: - Functions
	// swiftlint:disable redundant_discardable_let
	/// Initialise Pusher and connect to subsequent channels
	func registerForPusher() {
		if let currentID = User.currentID, currentID != 0 {
			pusher.connect()

			let myChannel = pusher.subscribe("private-user.\(currentID)")

			let _ = myChannel.bind(eventName: "session.new", callback: { [weak self] (data: Any?) -> Void in
				if let data = data as? [String: AnyObject] {
					if let sessionID = data["id"] as? Int, let device = data["device"] as? String, let ip = data["ip"] as? String, let lastValidated = data["last_validated"] as? String {
						if sessionID != User.currentSessionID {
							self?.notificationsHandler(device)

							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id": sessionID, "ip": ip, "device": device, "last_validated": lastValidated])
						}
					} else {
						NSLog("------- Pusher error -------")
					}
				}
			})

			let _ = myChannel.bind(eventName: "session.killed", callback: { [weak self] (data: Any?) -> Void in
				if let data = data as? [String: AnyObject], data.count != 0 {
					if let sessionID = data["session_id"] as? Int, let sessionKillerId = data["killer_session_id"] as? Int, let signOutReason = data["reason"] as? String {
						let isKiller = User.currentSessionID == sessionKillerId

						if sessionID == User.currentSessionID, !isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
							self?.signOut(with: signOutReason, whereUser: isKiller)
						} else if sessionID == User.currentSessionID, isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
						} else {
							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil, userInfo: ["session_id": sessionID])
						}
					}
				} else {
					NSLog("------- Pusher error -------")
				}
			})
		}
	}

	/**
		Checks whether the current user is signed in. If the user is signed in then a success block is run. Otherwise the user is asked to sign in.

		- Parameter completion: Optional completion handler (default is `nil`).
	*/
	func isSignedIn(_ completion: (() -> Void)? = nil) {
		if User.isSignedIn {
			completion?()
		} else {
			if let signInTableViewController = SignInTableViewController.instantiateFromStoryboard() as? SignInTableViewController {
				let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
				UIApplication.topViewController?.present(kNavigationController)
			}
		}
	}

	/**
		Sign out the current user by emptying KDefaults. Also show a message with the reason of the sign out if the user's session was terminated from a different device.

		- Parameter signOutReason: The reason as to why the user has been signed out.
		- Parameter isKiller: A boolean indicating whether the current user is the one who initiated the sign out.
	*/
	func signOut(with signOutReason: String? = nil, whereUser isKiller: Bool = false) {
		try? Kurozora.shared.KDefaults.removeAll()
		NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
	}
}

// MARK: - In-App Notification handlers
extension WorkflowController {
	/// Open the sessions view if the current view is not the sessions view.
	func showSessions() {
		if UIApplication.topViewController as? ManageActiveSessionsController == nil {
			let storyBoard = UIStoryboard(name: "settings", bundle: nil)
			let manageActiveSessionsController = storyBoard.instantiateViewController(withIdentifier: "ManageActiveSessionsController") as? ManageActiveSessionsController
			manageActiveSessionsController?.dismissEnabled = true
			let kurozoraNavigationController = KNavigationController(rootViewController: manageActiveSessionsController!)
			UIApplication.topViewController?.present(kurozoraNavigationController)
		}
	}

	/**
		Handles which type of notification to show according to the user's notification settings.

		- Parameter device: The name of the device a new session was created on.
	*/
	func notificationsHandler(_ device: String) {
		// If notifications enabled
		if UserSettings.notificationsAllowed {
			let alertType = UserSettings.alertType

			if alertType == 0 || alertType == 1 {
				var banner = NotificationBanner(title: "New sign in detected from " + device, subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: #imageLiteral(resourceName: "session_icon")), style: .info)

				if alertType == 0 {
					banner = NotificationBanner(title: "New sign in detected from " + device, subtitle: "(Tap to manage your sessions!)", style: .info)
				}

				// Notification haptic feedback and vibration
				banner.haptic = (UserSettings.notificationsVibration) ? .heavy : .none

				// Notification sound feedback
				//				banner.sound = (UserSettings.notificationsSound) ? .success : .none

				// Notification persistency
				if UserSettings.notificationsPersistent == 0 {
					banner.autoDismiss = true
				} else {
					banner.autoDismiss = false
					banner.onSwipeUp = {
						banner.dismiss()
					}
				}
				banner.show()
				banner.onTap = {
					self.showSessions()
				}
			} else if alertType == 2 {
				let statusBanner = StatusBarNotificationBanner(title: "New sign in detected from " + device, style: .info)

				// Notification haptic feedback and vibration
				statusBanner.haptic = (UserSettings.notificationsVibration) ? .heavy : .none

				// Notification sound feedback
				//				statusBanner.sound = (UserSettings.notificationsSound) ? .success : .none

				// Notification persistency
				if UserSettings.notificationsPersistent == 0 {
					statusBanner.autoDismiss = true
				} else {
					statusBanner.autoDismiss = false
					statusBanner.onSwipeUp = {
						statusBanner.dismiss()
					}
				}
				statusBanner.show()
				statusBanner.onTap = {
					self.showSessions()
				}
			}
		}
	}
}

// MARK: - Push Notifications
extension WorkflowController {
	/// Asks the user for permission to register the device for push notifications.
	func registerForPushNotifications() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in

			print("Permission granted: \(granted)")

			guard granted else { return }
			self?.getNotificationSettings()
		}
	}

	/// Registers the device for push notifications if authorized.
	func getNotificationSettings() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			print("Notification settings: \(settings)")

			guard settings.authorizationStatus == .authorized else { return }
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		}
	}
}
