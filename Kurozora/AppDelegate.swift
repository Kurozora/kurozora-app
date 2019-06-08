//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import IQKeyboardManagerSwift
import RevealingSplashView
import Kingfisher
import SCLAlertView
import SwiftTheme
import TRON

let heartAttackNotification = Notification.Name("heartAttackNotification")
let updateAppIconNotification = Notification.Name("updateAppIconNotification")
let updateNotificationSettingsValueLabelsNotification = Notification.Name("updateNotificationSettingsValueLabelsNotification")
let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "kurozora_icon"), iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: ThemeManager.color(for: KThemePicker.backgroundColor.stringValue()) ?? #colorLiteral(red: 0.2078431373, green: 0.2274509804, blue: 0.3137254902, alpha: 1))

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var authenticated = false
	var isUnreachable = false
	let libraryDirectoryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
		// Initialize theme
		let themesDirectoryUrl: URL = libraryDirectoryUrl.appendingPathComponent("Themes/")

		if UserSettings.automaticNightTheme {
			KThemeStyle.checkSunSchedule()
		} else if let themeIDString = UserSettings.currentTheme, themeIDString != "" {
			// If themeID is an integer
			if let themeID = Int(themeIDString) {
				// Use a non default theme if it exists
				if FileManager.default.fileExists(atPath: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist").path) {
					KThemeStyle.switchTo(theme: themeID)
				} else {
					// Fallback to default if theme doesn't exist
					KThemeStyle.switchTo(.day)
				}
			} else {
				// Use one of the chosen default themes
				KThemeStyle.switchTo(theme: themeIDString)
			}
		} else {
			// Fallback to default if no theme is chosen
			KThemeStyle.switchTo(.day)
		}

		// Initialize UIWindow
		window = UIWindow()
		window?.makeKeyAndVisible()

//		// If the network is unreachable show the offline page
//		KNetworkManager.isUnreachable { _ in
//			self.isUnreachable = true
//		}
//
//		if isUnreachable {
//			Kurozora.showOfflinePage(for: window)
//			return true
//		}
//
//		// Monitor network availability
//		KNetworkManager.shared.reachability.whenUnreachable = { _ in
//			Kurozora.showOfflinePage(for: nil)
//		}
//
//		// Initialize Pusher
//		WorkflowController.pusherInit()
//
//        // Max disk cache size
//		ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024
//
		// Global app tint color
		self.window?.theme_tintColor = KThemePicker.tintColor.rawValue

        // IQKeyoardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//
//		// User login status
//        if User.username() != nil {
//			authenticated = true
//            let customTabBar = KurozoraTabBarController()
//            self.window?.rootViewController = customTabBar
//        } else {
//            revealingSplashView.heartAttack = true
//            let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as? WelcomeViewController
//            self.window?.rootViewController = vc

		let storyboard: UIStoryboard = UIStoryboard(name: "settings", bundle: nil)
		let vc = storyboard.instantiateInitialViewController()
		self.window?.rootViewController = vc
//        }
//
//        window?.addSubview(revealingSplashView)
//		revealingSplashView.playHeartBeatAnimation()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleHeartAttackNotification), name: heartAttackNotification, object: nil)

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
//		KNetworkManager.isReachable { _ in
//			self.authenticated = Kurozora.validateSession(window: self.window)
			if UserSettings.automaticNightTheme {
				KThemeStyle.checkSunSchedule()
			}
//		}
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if authenticated {
			Kurozora.schemeHandler(app, open: url, options: options)
		}

		return true
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		if userActivity.activityType == "OpenAnimeIntent", let parameters = userActivity.userInfo as? [String: Int] {
			let showID = parameters["showID"]
			let storyboard = UIStoryboard(name: "details", bundle: nil)
			if let showTabBarController = storyboard.instantiateViewController(withIdentifier: "ShowTabBarController") as? ShowTabBarController {
				showTabBarController.showID = showID

				UIApplication.topViewController()?.present(showTabBarController, animated: true)
			}
			return true
		}

		return false
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		if authenticated {
			Kurozora.shortcutHandler(application, shortcutItem)
		}
	}
}
