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

class WorkflowController: NSObject {
	// MARK: - Properties
	/// Returns the singleton WorkflowController instance.
	static let shared = WorkflowController()
	static let optionsWithEndpoint = PusherClientOptions(authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder()), host: .cluster("eu"))
	var pusher: Pusher = Pusher(key: "edc954868bb006959e45", options: optionsWithEndpoint)
	let notificationCenter = UNUserNotificationCenter.current()

	// MARK: - Initializer
	private override init() {}

	// MARK: - Functions
	// swiftlint:disable redundant_discardable_let
	/// Initialise Pusher and connect to subsequent channels
	func registerForPusher() {
		if User.currentID != 0 {
			pusher.connect()

			let myChannel = pusher.subscribe("private-user.\(User.currentID)")

			let _ = myChannel.bind(eventName: "session.new", callback: { [weak self] (data: Any?) -> Void in
				if let data = data as? [String: AnyObject] {
					if let sessionID = data["id"] as? Int, let device = data["device"] as? String, let ip = data["ip"] as? String, let lastValidated = data["last_validated"] as? String {
						if sessionID != User.currentSessionID {
							self?.notificationsHandler(device)

							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id": sessionID, "ip": ip, "device": device, "last_validated": lastValidated])

							self?.scheduleNotification("New session", body: "New sign in detected from \(device)")
						}
					} else {
						print("------- Pusher error -------")
					}
				}
			})

			let _ = myChannel.bind(eventName: "session.killed", callback: { [weak self] (data: Any?) -> Void in
				if let data = data as? [String: AnyObject], data.count != 0 {
					if let sessionID = data["session_id"] as? Int, let sessionKillerId = data["killer_session_id"] as? Int, let signOutReason = data["reason"] as? String {
						let isKiller = User.currentSessionID == sessionKillerId

						if sessionID == User.currentSessionID, !isKiller {
							self?.pusher.unsubscribeAll()
							self?.pusher.disconnect()
							self?.signOut(with: signOutReason, whereUser: isKiller)
						} else if sessionID == User.currentSessionID, isKiller {
							self?.pusher.unsubscribeAll()
							self?.pusher.disconnect()
						} else {
							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil, userInfo: ["session_id": sessionID])
						}
					}
				} else {
					print("------- Pusher error -------")
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
		User.removeProfileImage()
		NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		if signOutReason != nil {
			SCLAlertView().showWarning("Signed out", subTitle: signOutReason)
		}
	}
}

// MARK: - In-App Notification handlers
extension WorkflowController {
	/// Open the sessions view if the current view is not the sessions view.
	func showSessions() {
		if UIApplication.topViewController as? ManageActiveSessionsController == nil {
			if let manageActiveSessionsController = ManageActiveSessionsController.instantiateFromStoryboard() as? ManageActiveSessionsController {
				manageActiveSessionsController.dismissEnabled = true
				let kurozoraNavigationController = KNavigationController(rootViewController: manageActiveSessionsController)
				UIApplication.topViewController?.present(kurozoraNavigationController)
			}
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
			var banner: BaseNotificationBanner?

			if alertType == 0 {
				banner = FloatingNotificationBanner(title: "New sign in detected from " + device, subtitle: "(Tap to manage your sessions!)", style: .info)
			} else if alertType == 1 {
				banner = FloatingNotificationBanner(title: "New sign in detected from " + device, subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: #imageLiteral(resourceName: "session_icon")), style: .info)
			} else if alertType == 2 {
				banner = StatusBarNotificationBanner(title: "New sign in detected from " + device, style: .info)
			}

			// Notification haptic feedback and vibration
			banner?.haptic = (UserSettings.notificationsVibration) ? .heavy : .none

			// Notification sound feedback
//			banner?.sound = (UserSettings.notificationsSound) ? .success : .none

			// Notification persistency
			if UserSettings.notificationsPersistent == 0 {
				banner?.autoDismiss = true
			} else {
				banner?.autoDismiss = false
				banner?.onSwipeUp = {
					banner?.dismiss()
				}
			}
			banner?.onTap = {
				self.showSessions()
			}

			if alertType == 0 || alertType == 1 {
				(banner as? FloatingNotificationBanner)?.show(cornerRadius: 10, shadowBlurRadius: 15, shadowCornerRadius: 15)
			} else {
				banner?.show()
			}
		}
	}
}

// MARK: - Push Notifications
extension WorkflowController {
	func scheduleNotification(_ title: String, body: String) {
		// Prepare local notification
		let date = Date()
		let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
		let identifier = "Local Notification"

		// Prepare actions for notification
		let showSessionAction = UNNotificationAction(identifier: "NEW_SESSION", title: "Show", options: [])
		let sessionActions = "Session Actions"
		let category = UNNotificationCategory(identifier: sessionActions, actions: [showSessionAction], intentIdentifiers: [], options: [])

		// Create notification content
		let content = UNMutableNotificationContent()
		content.title = "\(title)"
		content.body = "\(body)"
		content.sound = UNNotificationSound.default
		content.badge = 1
		content.categoryIdentifier = sessionActions
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

		// Add notification actions
		notificationCenter.setNotificationCategories([category])
		notificationCenter.delegate = self

		// Add notification to notification center
		notificationCenter.add(request) { (error) in
			if let error = error {
				print("Error \(error.localizedDescription)")
			}
		}
	}

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

// MARK: - UNUserNotificationCenterDelegate
extension WorkflowController: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		// Perform the task associated with the action.
		switch response.actionIdentifier {
		case "NEW_SESSION":
			self.showSessions()
		default:
			break
		}

		// Always call the completion handler when done.
		completionHandler()
	}
}
