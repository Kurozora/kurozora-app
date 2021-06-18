//
//  UIApplication+KurozoraKit.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/11/2020.
//

internal extension UIApplication {
	/**
		Return the top (root) view controller of a given view controller.

		If no base view controller is specified then this function returms the application root view controller.

		- Parameter base: The base view controller that a view controller will be presented on top of.

		- Returns: the top (root) view controller of a given view controller.
	*/
	private class func topViewController(_ base: UIViewController?) -> UIViewController? {
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
		let base = UIApplication.sharedKeyWindow?.rootViewController
		return UIApplication.topViewController(base)
	}

	/// The shared key window of the application.
	static var sharedKeyWindow: UIWindow? {
		guard let scene = UIApplication.shared.connectedScenes.first,
			  let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
			  let window = windowSceneDelegate.window else {
				  return nil
			  }
		return window
	}
}
