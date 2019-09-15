//
//  UIApplication+Navigation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIApplication {
	/**
		Return the top (root) view controller of a given view controller.

		If no base view controller is specified then this function returms the application root view controller.

		- Parameter base: The base view controller that a view controller will be presented on top of.

		- Returns: the top (root) view controller of a given view controller.
	*/
	private class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			let top = topViewController(nav.visibleViewController)
			return top
		}

		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController {
				let top = topViewController(selected)
				return top
			}
		}

		if let presented = base?.presentedViewController {
			let top = topViewController(presented)
			return top
		}
		return base
	}

	/// The root view controller of the application.
	static var topViewController: UIViewController? {
		var base: UIViewController?
		if #available(iOS 13.0, *) {
			for scene in UIApplication.shared.connectedScenes where scene.activationState == .foregroundInactive {
				if let scene = scene as? UIWindowScene {
					if let sceneDelegate = scene.delegate as? UIWindowSceneDelegate {
						if let sceneWindow = sceneDelegate.window {
							base = sceneWindow?.rootViewController
						}
					}
				}
			}
		}
		return UIApplication.topViewController(base)
	}
}
