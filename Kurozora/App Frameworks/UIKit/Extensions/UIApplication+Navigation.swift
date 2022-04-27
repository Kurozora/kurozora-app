//
//  UIApplication+Navigation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SafariServices

extension UIApplication {
	/// Attempts to open the resource at the specified URL asynchronously in the browser specified by the user or in the corresponding app if a deep link is used.
	///
	/// - Parameters:
	///    - url: A URL (Universal Resource Locator). The resource identified by this URL may be local to the current app or it may be one that must be provided by a different app. UIKit supports many common schemes, including the http, https, tel, facetime, and mailto schemes. You can also employ custom URL schemes associated with apps installed on the device.
	///    - deepLink: A URL (Universal Resource Locator). The resource identified by this URL may be local to the current app or it may be one that must be provided by a different app. UIKit supports many common schemes, including the http, https, tel, facetime, and mailto schemes. You can also employ custom URL schemes associated with apps installed on the device.
	///    - options: A dictionary of options to use when opening the URL. For a list of possible keys to include in this dictionary, see UIApplication.OpenExternalURLOptionsKey.
	///    - completionHandler: The block to execute with the results. Provide a value for this parameter if you want to be informed of the success or failure of opening the URL. This block is executed asynchronously on your app's main thread. The block has no return value and takes the following parameter:
	///    - success: A Boolean indicating whether the URL was opened successfully.
	func kOpen(_ url: URL?, deepLink: URL? = nil, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler completion: ((_ success: Bool) -> Void)? = nil) {
		if let deepLink = deepLink, UIApplication.shared.canOpenURL(deepLink) {
			UIApplication.shared.open(deepLink, options: options, completionHandler: completion)
		}

		if let url = url {
			if UserSettings.defaultBrowser == .kurozora {
				let sfSafariViewController = SFSafariViewController(url: url)
				UIApplication.topViewController?.present(sfSafariViewController, animated: true, completion: nil)
			} else {
				UIApplication.shared.open(url.withPreferredScheme(), options: options, completionHandler: completion)
			}
		}
	}

	/// Return the top (root) view controller of a given view controller.
	///
	/// If no base view controller is specified then this function returms the application root view controller.
	///
	/// - Parameter base: The base view controller that a view controller will be presented on top of.
	///
	/// - Returns: the top (root) view controller of a given view controller.
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

		if let split = base as? UISplitViewController {
			if let firstView = split.viewController(for: .secondary) {
				let top = topViewController(firstView)
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
