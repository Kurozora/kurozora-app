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
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
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
