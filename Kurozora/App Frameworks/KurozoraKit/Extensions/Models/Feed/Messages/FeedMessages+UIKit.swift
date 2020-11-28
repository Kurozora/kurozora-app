//
//  FeedMessages+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension FeedMessage {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Heart and reply
			let heartAction = UIAction(title: "Like the Message", image: UIImage(systemName: "heart.fill")) { _ in
				self.heartMessage(via: viewController, userInfo: userInfo)
			}
			let replyAction = UIAction(title: "Reply to Message", image: R.image.symbols.message_fill()) { _ in
				self.replyToMessage(via: viewController, userInfo: userInfo)
			}
			let reShareAction = UIAction(title: "Re-share the Message", image: UIImage(systemName: "square.and.arrow.up.on.square.fill")) { _ in
				self.reShareMessage(via: viewController, userInfo: userInfo)
			}

			menuElements.append(heartAction)
			menuElements.append(replyAction)
			menuElements.append(reShareAction)
		}

		var userMenuElements: [UIMenuElement] = []
		// Replies action
		let showRepliesAction = UIAction(title: "Show Replies", image: R.image.symbols.message_fill()) { _ in
			self.visitRepliesView(from: viewController)
		}
		userMenuElements.append(showRepliesAction)

		// Username action
		if let user = self.relationships.users.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: "Show " + username + "'s Profile", image: UIImage(systemName: "person.crop.circle.fill")) { _ in
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: "Share Message", image: UIImage(systemName: "square.and.arrow.up")) { _ in
			self.openShareSheet(on: viewController)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report message action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: "Report Message", image: UIImage(systemName: "exclamationmark.circle.fill"), attributes: .destructive) { _ in
				self.reportMessage()
			}
			reportMenuElements.append(reportAction)

			// Append report menu
			menuElements.append(UIMenu(title: "", options: .displayInline, children: reportMenuElements))
		}

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/**
		Heart or un-heart the message.

		- Parameter viewController: The view controller initiating the action.
		- Parameter userInfo: Any infromation passed by the user.
	*/
	func heartMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		WorkflowController.shared.isSignedIn {
			KService.heartMessage(self.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessageHeart):
					self.attributes.update(heartStatus: feedMessageHeart.isHearted)

					if let indexPath = userInfo?["indexPath"] as? IndexPath {
						NotificationCenter.default.post(name: .KFTMessageDidUpdate, object: nil, userInfo: ["feedMessage": self, "indexPath": indexPath])
					}
				case .failure: break
				}
			}
		}
	}

	/**
		Presents the reply view for the current message.

		- Parameter viewController: The view controller initiating the action.
		- Parameter userInfo: Any infromation passed by the user.
	*/
	func replyToMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		WorkflowController.shared.isSignedIn {
			if let kfmReplyTextEditorViewController = R.storyboard.textEditor.kfmReplyTextEditorViewController() {
				kfmReplyTextEditorViewController.delegate = viewController as? KFeedMessageTextEditorViewDelegate
				kfmReplyTextEditorViewController.segueToOPFeedDetails = !(userInfo?["liveReplyEnabled"] as? Bool ?? false)
				kfmReplyTextEditorViewController.opFeedMessage = self

				let kurozoraNavigationController = KNavigationController.init(rootViewController: kfmReplyTextEditorViewController)
				kurozoraNavigationController.navigationBar.prefersLargeTitles = false
				viewController?.present(kurozoraNavigationController, animated: true)
			}
		}
	}

	/**
		Presents the re-share view for the current message.

		- Parameter viewController: The view controller initiating the action.
		- Parameter userInfo: Any infromation passed by the user.
	*/
	func reShareMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		WorkflowController.shared.isSignedIn {
			if !self.attributes.isReShared {
				if let kfmReShareTextEditorViewController = R.storyboard.textEditor.kfmReShareTextEditorViewController() {
					kfmReShareTextEditorViewController.delegate = viewController as? KFeedMessageTextEditorViewDelegate
					kfmReShareTextEditorViewController.segueToOPFeedDetails = !(userInfo?["liveReShareEnabled"] as? Bool ?? false)
					kfmReShareTextEditorViewController.opFeedMessage = self

					let kurozoraNavigationController = KNavigationController.init(rootViewController: kfmReShareTextEditorViewController)
					kurozoraNavigationController.navigationBar.prefersLargeTitles = false
					viewController?.present(kurozoraNavigationController, animated: true)
				}
			} else {
				viewController?.presentAlertController(title: "Can't Re-Share", message: "You are not allowed to re-share a message more than once.")
			}
		}
	}

	/**
		Presents the details view of the message.

		- Parameter viewController: The view controller initiaing the segue.
	*/
	func visitRepliesView(from viewController: UIViewController? = UIApplication.topViewController) {
		if let fmDetailsTableViewController = R.storyboard.feed.fmDetailsTableViewController() {
			fmDetailsTableViewController.feedMessageID = self.id

			viewController?.show(fmDetailsTableViewController, sender: nil)
		}
	}

	/**
		Presents the profile view for the message poster.

		- Parameter viewController: The view controller initiaing the segue.
	*/
	func visitOriginalPosterProfile(from viewController: UIViewController? = UIApplication.topViewController) {
		guard let user = self.relationships.users.data.first else { return }

		if let profileViewController = R.storyboard.profile.profileTableViewController() {
			profileViewController.userID = user.id
			profileViewController.dismissButtonIsEnabled = true

			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/**
		Present share sheet for the feed message.

		Make sure to send either the view or the bar button item that's sending the request.

		- Parameter viewController: The view controller presenting the share sheet.
		- Parameter view: The `UIView` sending the request.
		- Parameter barButtonItem: The `UIBarButtonItem` sending the request.
	*/
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		var shareText = "\"\(self.attributes.body)\""
		if let user = self.relationships.users.data.first {
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

	/// Sends a report of the selected message to the mods.
	func reportMessage() {
		WorkflowController.shared.isSignedIn {

		}
	}
}
