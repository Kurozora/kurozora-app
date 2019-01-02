//
//  WorkflowController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
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
		if let currentID = User.currentID(), currentID != 0 {
			pusher.connect()

			let myChannel = pusher.subscribe("private-user.\(currentID)")

			let _ = myChannel.bind(eventName: "session.new", callback: { (data: Any?) -> Void in
				if let data = data as? JSON {
					if let session = try? UserSessionsElement(json: data) {
						if let sessionID = session.id, let device = session.device, let ip = session.ip, let lastValidated = session.lastValidated  {
							if sessionID != User.currentSessionID() {
								notificationsHandler(device: device)

								NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id" : sessionID, "ip": ip, "device": device, "last_validated": lastValidated])
							}
						}
					}
				} else {
					NSLog("------- Pusher error -------")
				}

//				if let data = data as? [String : AnyObject], data.count != 0 {
//					if let sessionID = data["id"] as? Int, let device = data["device"] as? String, let ip = data["ip"] as? String, let lastValidated = data["last_validated"] as? String  {
//						if sessionID != User.currentSessionID() {
//							notificationsHandler()
//
//							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id" : sessionID, "ip": ip, "device": device, "last_validated": lastValidated])
//						}
//					}
//				} else {
//					NSLog("------- Pusher error -------")
//				}
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
							let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
							vc.logoutReason = reason
							vc.isKiller = isKiller

							UIApplication.topViewController()?.present(vc, animated: true)
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

	/// Logout the current user by emptying KDefaults
	class func logoutUser() {
		try? GlobalVariables().KDefaults.removeAll()

		let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
		UIApplication.topViewController()?.present(vc, animated: true)
	}

	class func showSessions() {
		if UIApplication.topViewController() as? ManageActiveSessionsController != nil {
		} else {
			let storyBoard = UIStoryboard(name: "settings", bundle: nil)

			let splitView = storyBoard.instantiateViewController(withIdentifier: "SettingsSplitView") as? UISplitViewController
			let kurozoraNavigationController = storyBoard.instantiateViewController(withIdentifier: "SettingsController") as? KurozoraNavigationController
			let vc = storyBoard.instantiateViewController(withIdentifier: "ActiveSessions") as? ManageActiveSessionsController

			kurozoraNavigationController?.setViewControllers([vc!], animated: true)
			splitView?.showDetailViewController(kurozoraNavigationController!, sender: nil)

			UIApplication.topViewController()?.present(splitView!, animated: true)
		}
	}

	class func notificationsHandler(device: String) {
		// If notifications enabled
		if UserSettings.notificationsAllowed() {

			let alertType = UserSettings.alertType()

			if alertType == 0 || alertType == 1 {
				var banner = NotificationBanner(title: "New login detected from " + device, subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: #imageLiteral(resourceName: "session_icon")), style: .info)

				if alertType == 0 {
					banner = NotificationBanner(title: "New login detected from " + device, subtitle: "(Tap to manage your sessions!)", style: .info)
				}

				// Notification haptic feedback and vibration
				if UserSettings.notificationsVibration() {
					banner.haptic = .heavy
				}
				// Notification persistency
				if UserSettings.notificationsPersistent() == 0 {
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
				if UserSettings.notificationsVibration() {
					statusBanner.haptic = .heavy
				}
				// Notification persistency
				if UserSettings.notificationsPersistent() == 0 {
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
