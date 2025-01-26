//
//  Review+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/11/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Review {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any?])
	-> UIContextMenuConfiguration? {
		let identifier = userInfo["identifier"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	func makeContextMenu(in viewController: UIViewController?, userInfo: [AnyHashable: Any?]) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		var userMenuElements: [UIMenuElement] = []

		// Username action
		if let user = self.relationships?.users?.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: "Show " + username + "'s Profile", image: UIImage(systemName: "person.crop.circle.fill")) { [weak self] _ in
				guard let self = self else { return }
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: "Share Review", image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report review action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: "Report Review", image: UIImage(systemName: "exclamationmark.circle.fill"), attributes: .destructive) { [weak self] _ in
				guard let self = self else { return }
				self.reportReview()
			}
			reportMenuElements.append(reportAction)

			// Append report menu
			menuElements.append(UIMenu(title: "", options: .displayInline, children: reportMenuElements))
		}

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Presents the profile view for the review poster.
	///
	/// - Parameter viewController: The view controller initiaing the segue.
	func visitOriginalPosterProfile(from viewController: UIViewController? = UIApplication.topViewController) {
		guard let user = self.relationships?.users?.data.first else { return }
		let profileTableViewController = ProfileTableViewController.`init`(with: user)

		viewController?.show(profileTableViewController, sender: nil)
	}

	/// Present share sheet for the review.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		var shareText = "\"\(self.attributes.description ?? "")\""
		if let user = self.relationships?.users?.data.first {
			shareText += "-\(user.attributes.username)"
		}

		let activityItems: [Any] = [shareText]
		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let view = view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}
		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Sends a report of the selected review to the mods.
	func reportReview() {
		WorkflowController.shared.isSignedIn {
			Task { @MainActor in
				UIApplication.topViewController?.presentAlertController(title: "Review Reported", message: "Thank you for helping keep the community safe.")
			}
		}
	}
}
