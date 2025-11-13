//
//  Session+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Session {
	/// Create a context menu configuration for the session.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the session.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Create a context menu for the session.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the session.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Sign out of session action
		let signOutOfSessionAction = UIAction(title: "Sign Out of Session", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { _ in
			if let indexPath = userInfo?["indexPath"] as? IndexPath {
				Task {
					await self.signOutOfSession(at: indexPath)
				}
			}
		}
		menuElements.append(signOutOfSessionAction)

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Sends a request to remove the session from the user's session list.
	func signOutOfSession(at indexPath: IndexPath) async {
		do {
			let sessionIdentity = SessionIdentity(id: self.id)
			_ = try await KService.deleteSession(sessionIdentity).value
			NotificationCenter.default.post(name: .KSSessionIsDeleted, object: nil, userInfo: ["indexPath": indexPath])
		} catch {
			print(error.localizedDescription)
		}
	}
}
