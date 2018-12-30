//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RevealingSplashView
import Kingfisher
import SCLAlertView
import TRON
import ESTabBarController_swift

let heartAttackNotification = Notification.Name("heartAttackNotification")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var authenticated = false

    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "kurozora_icon")!,iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor(red: 53/255, green: 58/255, blue: 80/255, alpha: 1))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
		WorkflowController.pusherInit()

        // Max disk cache size
        ImageCache.default.maxDiskCacheSize = 60 * 1024 * 1024

		// Global app tint color
		self.window?.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
        
        // Reachability
//        do {
//            Network.reachability = try Reachability(hostname: "www.google.com")
//            do {
//                try Network.reachability?.start()
//            } catch let error as Network.Error {
//                NSLog("---Reachability error 1: \(error)")
//            } catch {
//                NSLog("---Reachability error 2: \(error)")
//            }
//        } catch {
//            NSLog("---Reachability error 3: \(error)")
//        }
        
        // IQKeyoardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        // Main view controller
        window = UIWindow()
        window?.makeKeyAndVisible()

        if User.username() != nil {
			authenticated = true
            let customTabBar = KurozoraTabBarController()
            self.window?.rootViewController = customTabBar
        } else {
            revealingSplashView.heartAttack = true
            let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as? WelcomeViewController
            self.window?.rootViewController = vc
        }
        
        window?.addSubview(revealingSplashView)
		revealingSplashView.playHeartBeatAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleHeartAttackNotification), name: heartAttackNotification, object: nil)
        return true
    }
    
    @objc func handleHeartAttackNotification() {
        revealingSplashView.heartAttack = true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Service.shared.validateSession(withSuccess: { (success) in
            if !success {
				self.authenticated = false
                let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                self.window?.rootViewController = vc
			} else {
				self.authenticated = true
			}
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if authenticated {
			let urlScheme = url.host?.removingPercentEncoding

			if urlScheme == "anime" {
				let showID = url.lastPathComponent
				if showID != "" {
					let storyboard = UIStoryboard(name: "details", bundle: nil)
					if let showTabBarController = storyboard.instantiateViewController(withIdentifier: "ShowTabBarController") as? ShowTabBarController {
						showTabBarController.showID = Int(showID)

						UIApplication.topViewController()?.present(showTabBarController, animated: true)
					}
				}
			}

			if urlScheme == "profile" || urlScheme == "feed" || urlScheme == "timeline" {
				let userID = url.lastPathComponent
				if userID != "" {
					let storyboard = UIStoryboard(name: "profile", bundle: nil)
					if let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController {
						profileViewController.otherUserID = Int(userID)

						let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: profileViewController)

						UIApplication.topViewController()?.present(kurozoraNavigationController, animated: true)
					}
				} else {
					if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
						tabBarController.selectedIndex = 4
					}
				}
			}

			if urlScheme == "explore" || urlScheme == "home" {
				if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 0
				}
			}

			if urlScheme == "notification" || urlScheme == "notifications" {
				if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 3
				}
			}

			if urlScheme == "forum" || urlScheme == "forums" {
				if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 2
				}
			}

			if urlScheme == "library" || urlScheme == "mylibrary" || urlScheme == "my library" || urlScheme == "list" {
				if let tabBarController = UIApplication.topViewController()?.tabBarController as? ESTabBarController {
					tabBarController.selectedIndex = 2
				}
			}
		}

		return true
	}
}

