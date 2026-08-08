//
//  MiniPlayerSceneDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The scene delegate hosting the MiniPlayer window.
@available(iOS 17.0, *)
final class MiniPlayerSceneDelegate: UIResponder, UIWindowSceneDelegate {
	// MARK: - Properties
	/// The window hosting the MiniPlayer.
	var window: UIWindow?

	// MARK: - Functions
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		print("----- MiniPlayer scene will connect to session.")
		guard let windowScene = scene as? UIWindowScene else { return }

		if session.userInfo == nil {
			session.userInfo = [:]
		}
		session.userInfo?["isMiniPlayer"] = true

		KThemeStyle.initAppTheme()

		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = MiniPlayerViewController()
		window.theme_tintColor = KThemePicker.tintColor.rawValue
		window.alpha = 0
		self.window = window
		window.makeKeyAndVisible()

		windowScene.title = L10n.miniPlayer
		windowScene.sizeRestrictions?.minimumSize = MiniPlayerViewController.minimumWindowSize
		windowScene.sizeRestrictions?.maximumSize.width = MiniPlayerViewController.maximumWindowWidth
		windowScene.sizeRestrictions?.allowsFullScreen = false

		#if targetEnvironment(macCatalyst)
		// A toolbar would swallow clicks over the top chrome.
		windowScene.titlebar?.titleVisibility = .hidden
		windowScene.titlebar?.toolbar = nil
		#endif
	}
}
