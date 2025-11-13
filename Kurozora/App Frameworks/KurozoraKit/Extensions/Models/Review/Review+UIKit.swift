//
//  Review+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/11/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Review {
	/// Create a context menu configuration for the review.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the review.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?)
		-> UIContextMenuConfiguration?
	{
		let identifier = userInfo?["identifier"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
			self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Create a context menu for the review.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the review.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		var userMenuElements: [UIMenuElement] = []

		// Username action
		if let user = self.relationships?.users?.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: "Show " + username + "'s Profile", image: UIImage(systemName: "person.crop.circle.fill")) { _ in
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: Trans.shareReview, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report review action
			let reviewUserID = self.relationships?.users?.data.first?.id
			if User.current?.attributes.role == .superAdmin ||
				User.current?.attributes.role == .admin ||
				User.current?.id == reviewUserID
			{
				var deleteMenuElements: [UIMenuElement] = []
				// Delete action
				let deleteAction = UIAction(title: Trans.deleteReview, attributes: .destructive) { _ in
					self.confirmDelete(via: viewController, userInfo: userInfo)
				}
				deleteMenuElements.append(deleteAction)

				// Append report menu
				menuElements.append(UIMenu(title: Trans.delete, image: UIImage(systemName: "trash"), children: deleteMenuElements))
			}

			// Report review action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: Trans.reportReview, attributes: .destructive) { _ in
				Task {
					await self.reportReview(on: viewController)
				}
			}
			reportMenuElements.append(reportAction)

			// Append report menu
			menuElements.append(UIMenu(title: Trans.report, image: UIImage(systemName: "exclamationmark.circle"), children: reportMenuElements))
		}

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Presents the profile view for the review poster.
	///
	/// - Parameter viewController: The view controller initialing the segue.
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
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, sourceView: UIView?, barButtonItem: UIBarButtonItem?) {
		var activityItems: [Any] = []

		var shareText = "\"\(self.attributes.description ?? "")\""
		if let user = self.relationships?.users?.data.first {
			shareText += "-\(user.attributes.username)"
		}

		activityItems.append(shareText)

		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let sourceView = sourceView {
				popoverController.sourceView = sourceView
				popoverController.sourceRect = sourceView.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}
		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Sends a report of the selected review to the mods.
	@MainActor
	func reportReview(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		let viewController = viewController ?? UIApplication.topViewController
		viewController?.presentAlertController(title: Trans.reviewReportedHeadline, message: Trans.reviewReportedSubheadline)
	}

	/// Remove the review.
	///
	/// - Parameter indexPath: The index path of the review.
	private func remove(at indexPath: IndexPath) async {
		let reviewIdentity = ReviewIdentity(id: self.id)

		do {
			_ = try await KService.delete(reviewIdentity).value

			NotificationCenter.default.post(name: .KReviewDidDelete, object: nil, userInfo: ["indexPath": indexPath])
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Confirm if the user wants to delete the review.
	private func confirmDelete(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.alert(title: nil, message: Trans.deleteReviewSubheadline) { alertController in
			let deleteAction = UIAlertAction(title: Trans.deleteReview, style: .destructive) { _ in
				if let indexPath = userInfo?["indexPath"] as? IndexPath {
					Task {
						await self.remove(at: indexPath)
					}
				}
			}
			alertController.addAction(deleteAction)
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			if let view = viewController?.view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			}
		}

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}
}
