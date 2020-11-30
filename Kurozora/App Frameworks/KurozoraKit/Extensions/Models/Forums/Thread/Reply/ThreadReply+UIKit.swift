//
//  ThreadReply+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ThreadReply {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			let parentThread = userInfo?["parentThread"] as? ForumsThread

			// Upvote, downvote and reply actions
			if parentThread?.attributes.lockStatus == .unlocked, let indexPath = userInfo?["indexPath"] as? IndexPath {
				let upvoteAction = UIAction(title: "Upvote the Thread", image: UIImage(systemName: "arrow.up.circle.fill")) { _ in
					self.voteOnReply(as: .upVote, at: indexPath)
				}
				let downvoteAction = UIAction(title: "Downvote the Thread", image: UIImage(systemName: "arrow.down.circle.fill")) { _ in
					self.voteOnReply(as: .downVote, at: indexPath)
				}
//				let replyAction = UIAction(title: "Reply to Thread", image: #imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill")) { _ in
//					self.replyToReply(via: viewController)
//				}

				menuElements.append(upvoteAction)
				menuElements.append(downvoteAction)
//				menuElements.append(replyAction)
			}
		}

		var userMenuElements: [UIMenuElement] = []

		// Username action
		if let user = self.relationships.users.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: "Show " + username + "'s Profile", image: UIImage(systemName: "person.crop.circle.fill")) { _ in
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: "Share Reply", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report thread action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: "Report Thread", image: UIImage(systemName: "exclamationmark.circle.fill"), attributes: .destructive) { _ in
				self.reportReply()
			}

			reportMenuElements.append(reportAction)

			// Append report menu
			menuElements.append(UIMenu(title: "", options: .displayInline, children: reportMenuElements))
		}

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/**
	Present share sheet for the forums thread.

	Make sure to send either the view or the bar button item that's sending the request.

	- Parameter viewController: The view controller presenting the share sheet.
	- Parameter view: The `UIView` sending the request.
	- Parameter barButtonItem: The `UIBarButtonItem` sending the request.
	*/
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let threadURLString = "https://kurozora.app/thread/\(self.id)"
		let threadURL: Any = URL(string: threadURLString) ?? threadURLString
		var shareText = "\"\(self.attributes.content)\""
		if let user = self.relationships.users.data.first {
			shareText += "-\(user.attributes.username)"
		}

		let activityItems: [Any] = [threadURL, shareText]
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

	/**
		Vote on the reply with the given vote.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote the reply.
		- Parameter indexPath: The index path of the reply.
	*/
	func voteOnReply(as voteStatus: VoteStatus, at indexPath: IndexPath) {
		WorkflowController.shared.isSignedIn {
			KService.voteOnReply(self.id, withVoteStatus: voteStatus) { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success(let voteStatus):
					if voteStatus == .upVote {
						self.attributes.metrics.weight += 1
					} else if voteStatus == .downVote {
						self.attributes.metrics.weight -= 1
					}

					self.attributes.voteAction = voteStatus

					NotificationCenter.default.post(name: .KTRDidUpdate, object: nil, userInfo: ["indexPath": indexPath])
				case .failure: break
				}
			}
		}
	}

	/**
		Presents the reply view for the current reply.

		- Parameter viewController: The view controller initiating the action.
	*/
	func replyToReply(via viewController: UIViewController? = UIApplication.topViewController) {
		WorkflowController.shared.isSignedIn {
//			let kCommentEditorViewController = R.storyboard.textEditor.kCommentEditorViewController()
//			kCommentEditorViewController?.delegate = viewController as? KCommentEditorViewDelegate
//			kCommentEditorViewController?.forumsThread = self
//
//			let kurozoraNavigationController = KNavigationController.init(rootViewController: kCommentEditorViewController!)
//			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
//
//			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/**
		Presents the profile view for the thread poster.

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

	/// Sends a report of the selected thread to the mods.
	func reportReply() {
		WorkflowController.shared.isSignedIn {
			UIApplication.topViewController?.presentAlertController(title: "Reply Repoted", message: "Thank you for helping keep the community safe.")
		}
	}

	/**
		Builds and presents the thread reply's actions in an action sheet.

		Make sure to send either the view or the bar button item that's sending the request.

		- Parameter viewController: The view controller presenting the action sheet.
		- Parameter view: The `UIView` sending the request.
		- Parameter barButtonItem: The `UIBarButtonItem` sending the request.
		- Parameter userInfo: Any infromation passed by the user.
	*/
	func actionList(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			if User.isSignedIn {
				let parentThread = userInfo?["parentThread"] as? ForumsThread

				// Upvote, downvote and reply actions
				if parentThread?.attributes.lockStatus == .unlocked, let indexPath = userInfo?["indexPath"] as? IndexPath {
					let upvoteReplyAction = UIAlertAction(title: "Upvote the Reply", style: .default, handler: { (_) in
						self?.voteOnReply(as: .upVote, at: indexPath)
					})
					let downvoteReplyAction = UIAlertAction(title: "Downvote the Reply", style: .default, handler: { (_) in
						self?.voteOnReply(as: .downVote, at: indexPath)
					})
	//				let replyAction = UIAlertAction(title: "Reply to Thread", style: .default) { (_) in
	//					self?.replyToReply(via: viewController)
	//				}

					upvoteReplyAction.setValue(UIImage(systemName: "arrow.up.circle.fill"), forKey: "image")
					downvoteReplyAction.setValue(UIImage(systemName: "arrow.down.circle.fill"), forKey: "image")
	//				replyAction.setValue(#imageLiteral(resourceName: "Symbols/message.left.and.message.right.fill"), forKey: "image")

					upvoteReplyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
					downvoteReplyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
	//				replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

					actionSheetAlertController.addAction(upvoteReplyAction)
					actionSheetAlertController.addAction(downvoteReplyAction)
	//				alertController.addAction(replyAction)
				}
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
			let shareAction = UIAlertAction(title: "Share Reply", style: .default, handler: { _ in
				self?.openShareSheet(on: viewController)
			})
			shareAction.setValue(UIImage(systemName: "square.and.arrow.up.fill"), forKey: "image")
			shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(shareAction)

			if User.isSignedIn {
				// Report thread action
				let reportAction = UIAlertAction(title: "Report Reply", style: .destructive, handler: { (_) in
					self?.reportReply()
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
