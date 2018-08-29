//
//  WorkflowController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import UIKit
import KCommonKit
import KDatabaseKit

public class WorkflowController {

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
//
//    class func applicationWindow() -> UIWindow {
//        return UIApplication.shared.delegate!.window!!
//    }
    
    class func logoutUser() {
        // Send request to server


        // Logout MAL
//        User.logoutMyAnimeList()

        // Remove defaults
//        UserDefaults.standard.removeObject(forKey: LibraryController.LastSyncDateDefaultsKey)
//        UserDefaults.standard.removeObject(forKey: RootTabBar.ShowedMyAnimeListLoginDefault)
//        UserDefaults.standard.synchronize()
        try? GlobalVariables().KDefaults.remove("username")
        try? GlobalVariables().KDefaults.remove("session_secret")
        // Logout user
//        return User.logOutInBackground()

    }
}
