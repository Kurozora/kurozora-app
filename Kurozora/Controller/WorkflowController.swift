//
//  WorkflowController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
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
		if let currentId = User.currentId(), currentId != 0 {
			pusher.connect()

			let myChannel = pusher.subscribe("private-user.\(currentId)")

			let _ = myChannel.bind(eventName: "session.new", callback: { (data: Any?) -> Void in
				if let data = data as? [String : AnyObject], data.count != 0 {
					if let sessionId = data["id"] as? Int, let device = data["device"] as? String, let ip = data["ip"] as? String, let lastValidated = data["last_validated"] as? String  {
						if sessionId != User.currentSessionId() {
							let banner = NotificationBanner(title: "New login detected from \(device)", subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: #imageLiteral(resourceName: "session_icon")), style: .info)
							banner.haptic = .heavy
							banner.show()
							banner.onTap = {
								let storyBoard = UIStoryboard(name: "settings", bundle: nil)

								let splitView = storyBoard.instantiateViewController(withIdentifier: "SettingsSplitView") as? UISplitViewController
								let controller = storyBoard.instantiateViewController(withIdentifier: "SettingsController") as? KurozoraNavigationController
								let vc = storyBoard.instantiateViewController(withIdentifier: "ActiveSessions") as? ManageActiveSessionsController

								controller?.setViewControllers([vc!], animated: true)
								splitView?.showDetailViewController(controller!, sender: nil)

								UIApplication.topViewController()?.present(splitView!, animated: true)
							}

							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil, userInfo: ["id" : sessionId, "ip": ip, "device": device, "last_validated": lastValidated])
						}
					}
				} else {
					NSLog("------- Pusher error")
				}
			})

			let _ = myChannel.bind(eventName: "session.killed", callback: { (data: Any?) -> Void in
				if let data = data as? [String : AnyObject], data.count != 0 {
					if let sessionId = data["session_id"] as? Int, let sessionKillerId = data["killer_session_id"] as? Int, let reason = data["reason"] as? String {
						let isKiller = User.currentSessionId() == sessionKillerId

						if sessionId == User.currentSessionId(), !isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
							logoutUser()

							let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
							let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
							vc.logoutReason = reason
							vc.isKiller = isKiller

							UIApplication.topViewController()?.present(vc, animated: true)
						} else if sessionId == User.currentSessionId(), isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
						} else {
							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil, userInfo: ["session_id" : sessionId])
						}
					}
				} else {
					NSLog("------- Pusher error")
				}
			})
		}
	}

	/// Logout the current user by emptying KDefaults
	class func logoutUser() {
		try? GlobalVariables().KDefaults.removeAll()
	}
}
