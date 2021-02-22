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
		let identifier = userInfo?["identifier"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil, actionProvider: { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Heart, reply and reshare
			let heartAction = UIAction(title: "Like the Message", image: UIImage(systemName: "heart.fill")) { _ in
				self.heartMessage(via: viewController, userInfo: userInfo)
			}
			let replyAction = UIAction(title: "Reply to Message", image: #imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill")) { _ in
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
		let showRepliesAction = UIAction(title: "Show Replies", image: #imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill")) { _ in
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
		let shareAction = UIAction(title: "Share Message", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
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
						NotificationCenter.default.post(name: .KFTMessageDidUpdate, object: nil, userInfo: ["indexPath": indexPath])
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

		let profileTableViewController = ProfileTableViewController.`init`(with: user.id)
		profileTableViewController.dismissButtonIsEnabled = true

		let kurozoraNavigationController = KNavigationController.init(rootViewController: profileTableViewController)
		viewController?.present(kurozoraNavigationController, animated: true)
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
			UIApplication.topViewController?.presentAlertController(title: "Message Reported", message: "Thank you for helping keep the community safe.")
		}
	}

	/**
		Builds and presents the feed message actions in an action sheet.

		Make sure to send either the view or the bar button item that's sending the request.

		- Parameter viewController: The view controller presenting the action sheet.
		- Parameter view: The `UIView` sending the request.
		- Parameter barButtonItem: The `UIBarButtonItem` sending the request.
		- Parameter userInfo: Any infromation passed by the user.
	*/
	func actionList(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			if User.isSignedIn {
				// Heart, reply and reshare
				let heartAction = UIAlertAction(title: "Like the Message", style: .default, handler: { (_) in
					self?.heartMessage(via: viewController, userInfo: userInfo)
				})
				let replyAction = UIAlertAction(title: "Reply to Message", style: .default, handler: { (_) in
					self?.replyToMessage(via: viewController, userInfo: userInfo)
				})
				let reShareAction = UIAlertAction(title: "Re-share the Message", style: .default) { (_) in
					self?.reShareMessage(via: viewController, userInfo: userInfo)
				}

				heartAction.setValue(UIImage(systemName: "heart.fill"), forKey: "image")
				replyAction.setValue(#imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill"), forKey: "image")
				reShareAction.setValue(UIImage(systemName: "square.and.arrow.up.on.square.fill"), forKey: "image")

				heartAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				reShareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

				actionSheetAlertController.addAction(heartAction)
				actionSheetAlertController.addAction(replyAction)
				actionSheetAlertController.addAction(reShareAction)
			}

			// Username action
			if let user = self?.relationships.users.data.first {
				let username = user.attributes.username
				let userAction = UIAlertAction(title: "Show " + username + "'s Profile", style: .default, handler: { _ in
					self?.visitOriginalPosterProfile(from: viewController)
				})
				userAction.setValue(UIImage(systemName: "person.crop.circle.fill"), forKey: "image")
				userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(userAction)
			}

			// Share action
			let shareAction = UIAlertAction(title: "Share Message", style: .default, handler: { _ in
				self?.openShareSheet(on: viewController)
			})
			shareAction.setValue(UIImage(systemName: "square.and.arrow.up.fill"), forKey: "image")
			shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(shareAction)

			if User.isSignedIn {
				// Report thread action
				let reportAction = UIAlertAction(title: "Report Message", style: .destructive, handler: { (_) in
					self?.reportMessage()
				})
				reportAction.setValue(UIImage(systemName: "exclamationmark.circle.fill"), forKey: "image")
				reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(reportAction)
			}
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			if let view = view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}
		viewController?.present(actionSheetAlertController, animated: true, completion: nil)
	}
}
