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
				if let data = data as? [String : AnyObject], data.count != 0 {
					if let sessionID = data["id"] as? Int, let device = data["device"] as? String, let ip = data["ip"] as? String, let lastValidated = data["last_validated"] as? String  {
						if sessionID != User.currentSessionID() {
							let banner = NotificationBanner(title: "New login detected from \(device)", subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: #imageLiteral(resourceName: "session_icon")), style: .info)
							banner.haptic = .heavy
							banner.show()
							banner.onTap = {
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

							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id" : sessionID, "ip": ip, "device": device, "last_validated": lastValidated])
						}
					}
				} else {
					NSLog("------- Pusher error -------")
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
}
