//
//  SceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RevealingSplashView
import Kingfisher
import SCLAlertView
import SwiftTheme

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var authenticated = false
	var authenticationCount = 0
	var isUnreachable = false
	let libraryDirectoryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		// Initialize theme
		let themesDirectoryUrl: URL = libraryDirectoryUrl.appendingPathComponent("Themes/")

		if UserSettings.automaticDarkTheme {
			KThemeStyle.startAutomaticDarkThemeSchedule()
		} else if let currentThemeID = UserSettings.currentTheme, !currentThemeID.isEmpty {
			// If themeID is an integer
			if let themeID = Int(currentThemeID) {
				// Use a non default theme if it exists
				if FileManager.default.fileExists(atPath: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist").path) {
					KThemeStyle.switchTo(theme: themeID)
				} else {
					// Fallback to default if theme doesn't exist
					KThemeStyle.switchTo(.day)
				}
			} else {
				// Use one of the chosen default themes
				KThemeStyle.switchTo(theme: currentThemeID)
			}
		} else {
			// Fallback to default if no theme is chosen
			KThemeStyle.switchTo(.default)
		}

		// Initialize UIWindow
		window = UIWindow(windowScene: windowScene)
		window?.makeKeyAndVisible()

		// If the network is unreachable show the offline page
		KNetworkManager.isUnreachable { _ in
			self.isUnreachable = true
		}

		if isUnreachable {
			Kurozora.shared.showOfflinePage(for: window)
			return
		}

		// Monitor network availability
		KNetworkManager.shared.reachability.whenUnreachable = { _ in
			Kurozora.shared.showOfflinePage(for: nil)
		}

		// Initialize Pusher
		WorkflowController.pusherInit()

        // Max disk cache size
		ImageCache.default.diskStorage.config.sizeLimit = 300 * 1024 * 1024

		// Global app tint color
		self.window?.theme_tintColor = KThemePicker.tintColor.rawValue

        // IQKeyoardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

		// User login status
		if User.username != nil {
			authenticated = true
            let customTabBar = KTabBarController()
            self.window?.rootViewController = customTabBar
        } else {
			authenticated = false
            revealingSplashView.heartAttack = true
			let welcomeViewController = WelcomeViewController.instantiateFromStoryboard()
            self.window?.rootViewController = welcomeViewController
        }

		// Check if user should authenticate
		Kurozora.shared.userHasToAuthenticate()

        window?.addSubview(revealingSplashView)
		revealingSplashView.playHeartBeatAnimation()

		NotificationCenter.default.addObserver(self, selector: #selector(handleHeartAttackNotification), name: .KHeartAttackShouldHappen, object: nil)

		if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
			 if !configure(window: window, with: userActivity) {
				print("Failed to restore from \(userActivity)")
			 }
		}
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		Kurozora.shared.schemeHandler(scene: scene, open: url)
	}

	func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

	// MARK: - Functions
    @objc func handleHeartAttackNotification() {
        revealingSplashView.heartAttack = true
    }

    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if activity.title == "OpenShowDetail" {
			if let parameters = activity.userInfo as? [String: Int] {
			let showID = parameters["showID"]
				if let showDetailTabBarController = ShowDetailTabBarController.instantiateFromStoryboard() as? ShowDetailTabBarController {
					showDetailTabBarController.showID = showID
					if let tabBarController = window?.rootViewController as? KTabBarController {
						tabBarController.present(showDetailTabBarController)
						return true
					}
				}
            }
        }
        return false
    }
}
