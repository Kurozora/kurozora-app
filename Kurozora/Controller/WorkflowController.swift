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
var window: UIWindow?

public class WorkflowController {

	/// Initialise Pusher and connect to subsequent channels
	class func pusherInit() {
		if let currentId = User.currentId(), currentId != 0 {
			pusher.connect()

			let myChannel = pusher.subscribe("private-user.\(currentId)")

			let _ = myChannel.bind(eventName: "session.new", callback: { (data: Any?) -> Void in
				if let data = data as? [String : AnyObject], data.count != 0 {
					if let userId = data["user_id"] as? Int, let ip = data["ip"] as? String, let sessionId = data["session_id"] as? Int  {
						if sessionId != User.currentSessionId() {
							let banner = NotificationBanner(title: "New login for userID: \(userId)", subtitle: "ip: \(ip), sessionID: \(sessionId) ", style: .success)
							banner.show()
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
							window = UIWindow()
							window?.makeKeyAndVisible()

							pusher.unsubscribeAll()
							pusher.disconnect()
							logoutUser()

							let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
							let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
							vc.logoutReason = reason
							vc.isKiller = isKiller

							window?.rootViewController = vc
						} else if isKiller {
							pusher.unsubscribeAll()
							pusher.disconnect()
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

//    class func presentRootTabBar(animated: Bool) {
    
//        let home = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as! UINavigationController
//        let library = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController() as! UINavigationController
//        let profile = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! UINavigationController
//        let notifications = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "NotificationNav") as! UINavigationController
//        let notificationVC = notifications.viewControllers.first as! NotificationsViewController
        
        
//        let forum = UIStoryboard(name: "Forums", bundle: nil).instantiateInitialViewController() as! UINavigationController
//
//        let tabBarController = RootTabBar()
//
////        notificationVC.delegate = tabBarController
//
//        tabBarController.viewControllers = [home, library, profile, notifications, forum]
//
//        if animated {
//            changeRootViewController(vc: tabBarController, animationDuration: 0.5)
//        } else {
//            if let window = UIApplication.shared.delegate!.window {
//                window?.rootViewController = tabBarController
//                window?.makeKeyAndVisible()
//            }
//        }
        
//    }
    
//    class func presentWelcomeController(asRoot: Bool) {
//
//        let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() as! WelcomeViewController
//
//        if asRoot {
//            welcome.isInWindowRoot = true
//            applicationWindow().rootViewController = welcome
//            applicationWindow().makeKeyAndVisible()
//        } else {
//            applicationWindow().rootViewController?.present(welcome, animated: true, completion: nil)
//        }
//
//    }
    
//    class func changeRootViewController(vc: UIViewController, animationDuration: TimeInterval = 0.5) {
//
//        var window: UIWindow?
//
//        let appDelegate = UIApplication.shared.delegate!
//
//        if appDelegate.responds(to: #selector(getter: UIApplicationDelegate.window)) {
//            window = appDelegate.window!
//        }
//
//        if let window = window {
//            if window.rootViewController == nil {
//                window.rootViewController = vc
//                return
//            }
//
//            let snapshot = window.snapshotView(afterScreenUpdates: true)
//            vc.view.addSubview(snapshot!)
//            window.rootViewController = vc
//            window.makeKeyAndVisible()
//
//            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
//                snapshot?.alpha = 0.0
//            }, completion: {(finished) in
//                snapshot?.removeFromSuperview()
//            })
//        }
//    }

	/// Return a shared instance of UIApplication window
    class func applicationWindow() -> UIWindow {
        return UIApplication.shared.delegate!.window!!
    }
}
