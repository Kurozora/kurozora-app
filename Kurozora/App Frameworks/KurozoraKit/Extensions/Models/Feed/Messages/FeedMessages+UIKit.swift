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

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Heart, reply and reshare
			var heartAction: UIAction
			if self.attributes.isHearted ?? false {
				heartAction = UIAction(title: "Unlike", image: UIImage(systemName: "heart.slash.fill")) { [weak self] _ in
					guard let self = self else { return }
					self.heartMessage(via: viewController, userInfo: userInfo)
				}
			} else {
				heartAction = UIAction(title: "Like", image: UIImage(systemName: "heart.fill")) { [weak self] _ in
					guard let self = self else { return }
					self.heartMessage(via: viewController, userInfo: userInfo)
				}
			}
			let replyAction = UIAction(title: "Reply", image: #imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill")) { [weak self] _ in
				guard let self = self else { return }
				self.replyToMessage(via: viewController, userInfo: userInfo)
			}
			let reShareAction = UIAction(title: "Re-share", image: UIImage(systemName: "square.and.arrow.up.on.square.fill")) { [weak self] _ in
				guard let self = self else { return }
				self.reShareMessage(via: viewController, userInfo: userInfo)
			}

			menuElements.append(heartAction)
			menuElements.append(replyAction)
			menuElements.append(reShareAction)

			// Edit and delete
			if let currentUserID = User.current?.id, let messageUserID = self.relationships.users.data.first?.id, currentUserID == messageUserID {
				// Edit action
				let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil.circle.fill")) { [weak self] _ in
					guard let self = self else { return }
					self.editMessage(via: viewController, userInfo: userInfo)
				}
				menuElements.append(editAction)

				var deleteMenuElements: [UIMenuElement] = []
				// Delete action
				let deleteAction = UIAction(title: "Delete Message", attributes: .destructive) { [weak self] _ in
					guard let self = self else { return }
					if let indexPath = userInfo?["indexPath"] as? IndexPath {
						self.remove(at: indexPath)
					}
				}
				deleteMenuElements.append(deleteAction)

				menuElements.append(UIMenu(title: "Delete", image: UIImage(systemName: "trash.fill"), children: deleteMenuElements))
			}
		}

		var userMenuElements: [UIMenuElement] = []
		// Replies action
		let showRepliesAction = UIAction(title: "Show Replies", image: #imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.visitRepliesView(from: viewController)
		}
		userMenuElements.append(showRepliesAction)

		// Username action
		if let user = self.relationships.users.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: "Show " + username + "'s Profile", image: UIImage(systemName: "person.crop.circle.fill")) { [weak self] _ in
				guard let self = self else { return }
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: "Share Message", image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report message action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: "Report Message", image: UIImage(systemName: "exclamationmark.circle.fill"), attributes: .destructive) { [weak self] _ in
				guard let self = self else { return }
				self.reportMessage()
			}
			reportMenuElements.append(reportAction)

			// Append report menu
			menuElements.append(UIMenu(title: "", options: .displayInline, children: reportMenuElements))
		}

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Heart or un-heart the message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	func heartMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		WorkflowController.shared.isSignedIn {
			KService.heartMessage(self.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessageUpdate):
					self.attributes.update(using: feedMessageUpdate)

					if let indexPath = userInfo?["indexPath"] as? IndexPath {
						NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: ["indexPath": indexPath])
					}
				case .failure: break
				}
			}
		}
	}

	/// Presents the reply view for the current message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	func replyToMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		WorkflowController.shared.isSignedIn {
			self.openReplyTextEditor(via: viewController, userInfo: userInfo, isEditingMessage: false)
		}
	}

	/// Presents the re-share view for the current message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	func reShareMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		WorkflowController.shared.isSignedIn {
			if !self.attributes.isReShared {
				self.openReShareTextEditor(via: viewController, userInfo: userInfo, isEditingMessage: false)
			} else {
				viewController?.presentAlertController(title: "Can't Re-Share", message: "You are not allowed to re-share a message more than once.")
			}
		}
	}

	/// Presents the reply text editor on the given view controller. Otherwise the view is presented on the top most view controller.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	///    - isEditingMessage: Whether the user is editing a message.
	func openReplyTextEditor(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?, isEditingMessage: Bool) {
		if let kfmReplyTextEditorViewController = R.storyboard.textEditor.kfmReplyTextEditorViewController() {
			kfmReplyTextEditorViewController.delegate = viewController as? KFeedMessageTextEditorViewDelegate
			if isEditingMessage {
				kfmReplyTextEditorViewController.editingFeedMessage = self
				kfmReplyTextEditorViewController.opFeedMessage = self.relationships.parent?.data.first
				kfmReplyTextEditorViewController.userInfo = userInfo
			} else {
				kfmReplyTextEditorViewController.segueToOPFeedDetails = !(userInfo?["liveReplyEnabled"] as? Bool ?? false)
				kfmReplyTextEditorViewController.opFeedMessage = self
			}

			let kurozoraNavigationController = KNavigationController(rootViewController: kfmReplyTextEditorViewController)
			kurozoraNavigationController.presentationController?.delegate = kfmReplyTextEditorViewController
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
			kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
			kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
			kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
			kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/// Presents the re-share text editor on the given view controller. Otherwise the view is presented on the top most view controller.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	///    - isEditingMessage: Whether the user is editing a message.
	func openReShareTextEditor(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?, isEditingMessage: Bool) {
		if let kfmReShareTextEditorViewController = R.storyboard.textEditor.kfmReShareTextEditorViewController() {
			kfmReShareTextEditorViewController.delegate = viewController as? KFeedMessageTextEditorViewDelegate
			if isEditingMessage {
				kfmReShareTextEditorViewController.editingFeedMessage = self
				kfmReShareTextEditorViewController.opFeedMessage = self.relationships.parent?.data.first
				kfmReShareTextEditorViewController.userInfo = userInfo
			} else {
				kfmReShareTextEditorViewController.segueToOPFeedDetails = !(userInfo?["liveReShareEnabled"] as? Bool ?? false)
				kfmReShareTextEditorViewController.opFeedMessage = self
			}

			let kurozoraNavigationController = KNavigationController(rootViewController: kfmReShareTextEditorViewController)
			kurozoraNavigationController.presentationController?.delegate = kfmReShareTextEditorViewController
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
			kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
			kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
			kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
			kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/// Presents the default text editor on the given view controller. Otherwise the view is presented on the top most view controller.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	///    - isEditingMessage: Whether the user is editing a message.
	func openDefaultTextEditor(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?, isEditingMessage: Bool) {
		if let kFeedMessageTextEditorViewController = R.storyboard.textEditor.kFeedMessageTextEditorViewController() {
			if isEditingMessage {
				kFeedMessageTextEditorViewController.editingFeedMessage = self
				kFeedMessageTextEditorViewController.userInfo = userInfo
			}

			let kurozoraNavigationController = KNavigationController(rootViewController: kFeedMessageTextEditorViewController)
			kurozoraNavigationController.presentationController?.delegate = kFeedMessageTextEditorViewController
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
			kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
			kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
			kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
			kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/// Presents the edit view for the current message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any infromation passed by the user.
	func editMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		if self.attributes.isReply {
			self.openReplyTextEditor(via: viewController, userInfo: userInfo, isEditingMessage: true)
		} else if self.attributes.isReShare {
			self.openReShareTextEditor(via: viewController, userInfo: userInfo, isEditingMessage: true)
		} else {
			self.openDefaultTextEditor(via: viewController, userInfo: userInfo, isEditingMessage: true)
		}
	}

	/// Remove the feed message from the user's messages list.
	///
	/// - Parameter indexPath: The index path of the message.
	func remove(at indexPath: IndexPath) {
		KService.deleteMessage(self.id) { result in
			switch result {
			case .success:
				NotificationCenter.default.post(name: .KFMDidDelete, object: nil, userInfo: ["indexPath": indexPath])
			case .failure:
				break
			}
		}
	}

	/// Confirm if the user wants to delete the message.
	func confirmDelete(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: "Message will be deleted permanently.") { [weak self] actionSheetAlertController in
			guard let self = self else { return }

			let deleteAction = UIAlertAction(title: "Delete Message", style: .destructive) { _ in
				if let indexPath = userInfo?["indexPath"] as? IndexPath {
					self.remove(at: indexPath)
				}
			}
			deleteAction.setValue(UIImage(systemName: "trash.fill"), forKey: "image")
			deleteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(deleteAction)
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			if let view = viewController?.view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			}
		}

		viewController?.present(actionSheetAlertController, animated: true, completion: nil)
	}

	/// Presents the details view of the message.
	///
	/// - Parameter viewController: The view controller initiaing the segue.
	func visitRepliesView(from viewController: UIViewController? = UIApplication.topViewController) {
		if let fmDetailsTableViewController = R.storyboard.feed.fmDetailsTableViewController() {
			fmDetailsTableViewController.feedMessageID = self.id

			viewController?.show(fmDetailsTableViewController, sender: nil)
		}
	}

	/// Presents the profile view for the message poster.
	///
	/// - Parameter viewController: The view controller initiaing the segue.
	func visitOriginalPosterProfile(from viewController: UIViewController? = UIApplication.topViewController) {
		guard let user = self.relationships.users.data.first else { return }

		let profileTableViewController = ProfileTableViewController.`init`(with: user.id)
		profileTableViewController.dismissButtonIsEnabled = true

		let kurozoraNavigationController = KNavigationController(rootViewController: profileTableViewController)
		viewController?.present(kurozoraNavigationController, animated: true)
	}

	/// Present share sheet for the feed message.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
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

	/// Builds and presents the feed message actions in an action sheet.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the action sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///    - userInfo: Any infromation passed by the user.
	func actionList(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			if User.isSignedIn {
				// Heart, reply and reshare
				var heartAction: UIAlertAction
				if self.attributes.isHearted ?? false {
					heartAction = UIAlertAction(title: "Unlike", style: .default) { _ in
						self.heartMessage(via: viewController, userInfo: userInfo)
					}
				} else {
					heartAction = UIAlertAction(title: "Like", style: .default) { _ in
						self.heartMessage(via: viewController, userInfo: userInfo)
					}
				}
				let replyAction = UIAlertAction(title: "Reply", style: .default) { _ in
					self.replyToMessage(via: viewController, userInfo: userInfo)
				}
				let reShareAction = UIAlertAction(title: "Re-share", style: .default) { _ in
					self.reShareMessage(via: viewController, userInfo: userInfo)
				}

				if self.attributes.isHearted ?? false {
					heartAction.setValue(UIImage(systemName: "heart.slash.fill"), forKey: "image")
				} else {
					heartAction.setValue(UIImage(systemName: "heart.fill"), forKey: "image")
				}
				replyAction.setValue(#imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill"), forKey: "image")
				reShareAction.setValue(UIImage(systemName: "square.and.arrow.up.on.square.fill"), forKey: "image")

				heartAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				reShareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

				actionSheetAlertController.addAction(heartAction)
				actionSheetAlertController.addAction(replyAction)
				actionSheetAlertController.addAction(reShareAction)

				// Edit and delete
				if let currentUserID = User.current?.id, let messageUserID = self.relationships.users.data.first?.id, currentUserID == messageUserID {
					let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
						self.editMessage(via: viewController, userInfo: userInfo)
					}
					let deleteAction = UIAlertAction(title: "Delete", style: .default) { _ in
						self.confirmDelete(via: viewController, userInfo: userInfo)
					}

					editAction.setValue(UIImage(systemName: "pencil.circle.fill"), forKey: "image")
					deleteAction.setValue(UIImage(systemName: "trash.fill"), forKey: "image")

					editAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
					deleteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

					actionSheetAlertController.addAction(editAction)
					actionSheetAlertController.addAction(deleteAction)
				}
			}

			// Username action
			if let user = self.relationships.users.data.first {
				let username = user.attributes.username
				let userAction = UIAlertAction(title: "Show " + username + "'s Profile", style: .default) { _ in
					self.visitOriginalPosterProfile(from: viewController)
				}
				userAction.setValue(UIImage(systemName: "person.crop.circle.fill"), forKey: "image")
				userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(userAction)
			}

			// Share action
			let shareAction = UIAlertAction(title: "Share Message", style: .default) { _ in
				self.openShareSheet(on: viewController)
			}
			shareAction.setValue(UIImage(systemName: "square.and.arrow.up.fill"), forKey: "image")
			shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(shareAction)

			if User.isSignedIn {
				// Report thread action
				let reportAction = UIAlertAction(title: "Report Message", style: .destructive) { _ in
					self.reportMessage()
				}
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
