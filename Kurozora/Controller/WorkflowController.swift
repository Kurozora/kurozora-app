//
//  WorkflowController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import PusherSwift
import NotificationBannerSwift
import SCLAlertView
import SwiftyJSON

let optionsWithEndpoint = PusherClientOptions(
	authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder()),
	host: .cluster("eu")
)
let pusher = Pusher(key: "edc954868bb006959e45", options: optionsWithEndpoint)

public class WorkflowController {
	/// Initialise Pusher and connect to subsequent channels
	class func pusherInit() {
		if let currentID = User.currentID, currentID != 0 {
			pusher.connect()

			let myChannel = pusher.subscribe("private-user.\(currentID)")

			let _ = myChannel.bind(eventName: "session.new", callback: { (data: Any?) -> Void in
				if let data = data as? [String : AnyObject] {
					if let sessionID = data["id"] as? Int, let device = data["device"] as? String, let ip = data["ip"] as? String, let lastValidated = data["last_validated"] as? String  {
						if sessionID != User.currentSessionID() {
							notificationsHandler(device)

							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id" : sessionID, "ip": ip, "device": device, "last_validated": lastValidated])
						}
					} else {
						NSLog("------- Pusher error -------")
					}
				}
			})

			let _ = myChannel.bind(eventName: "session.killed", callback: { (data: Any?) -> Void in
				if let data = data as? [String : AnyObject], data.count != 0 {
					if let sessionID = data["session_id"] as? Int, let sessionKillerId = data["killer_session_id"] as? Int, let reason = data["reason"] as? String {
						let isKiller = User.currentSessionID() == sessionKillerId

						if sessionID == User.currentSessionID(), !isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
							logoutUser()

							let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
							let vc = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
							vc.logoutReason = reason
							vc.isKiller = isKiller

							UIApplication.topViewController?.present(vc, animated: true)
						} else if sessionID == User.currentSessionID(), isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
						} else {
							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil, userInfo: ["session_id" : sessionID])
						}
					}
				} else {
					NSLog("------- Pusher error -------")
				}
			})
		}
	}

	/// Logout the current user by emptying KDefaults.
	class func logoutUser() {
		try? GlobalVariables().KDefaults.removeAll()

		let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
		UIApplication.topViewController?.present(vc, animated: true)
	}

	/// Open the sessions view.
	class func showSessions() {
		if UIApplication.topViewController as? ManageActiveSessionsController != nil {
		} else {
			let storyBoard = UIStoryboard(name: "settings", bundle: nil)
			let manageActiveSessionsController = storyBoard.instantiateViewController(withIdentifier: "ManageActiveSessionsController") as? ManageActiveSessionsController
			manageActiveSessionsController?.dismissEnabled = true
			let kurozoraNavigationController = KNavigationController.init(rootViewController: manageActiveSessionsController!)

			UIApplication.topViewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/**
		Handles which type of notification to show according to the user's notification settings.

		- Parameter device: The name of the device a new session was created on.
	*/
	class func notificationsHandler(_ device: String) {
		// If notifications enabled
		if UserSettings.notificationsAllowed {
			let alertType = UserSettings.alertType

			if alertType == 0 || alertType == 1 {
				var banner = NotificationBanner(title: "New login detected from " + device, subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: #imageLiteral(resourceName: "session_icon")), style: .info)

				if alertType == 0 {
					banner = NotificationBanner(title: "New login detected from " + device, subtitle: "(Tap to manage your sessions!)", style: .info)
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
				let statusBanner = StatusBarNotificationBanner(title: "New login detected from " + device, style: .info)

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
