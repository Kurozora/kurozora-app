//
//  UIApplication+Navigation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIApplication {
	/// Present a view controller on top of the root view controller
	private class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			let top = topViewController(nav.visibleViewController)
			return top
		}

		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController
			{
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

	/// Present a view controller on top of the root view controller
	static var topViewController: UIViewController? {
		return UIApplication.topViewController()
	}
}
