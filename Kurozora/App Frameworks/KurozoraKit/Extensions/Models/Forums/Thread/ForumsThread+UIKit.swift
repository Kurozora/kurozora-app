//
//  ForumsThread+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ForumsThread {
//	var upVoteCompletion: ((_ forumsThread: ForumsThread)->()) {
//		return (forumsThread: self)
//	}

	func contextMenuConfiguration(in viewController: UIViewController)
	-> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
			return self.makeContextMenu(in: viewController)
		})
	}

	private func makeContextMenu(in viewController: UIViewController) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Upvote, downvote and reply actions
			if self.attributes.lockStatus == .unlocked {
				let upvoteAction = UIAction(title: "Upvote the Thread", image: UIImage(systemName: "arrow.up.circle.fill")) { _ in
					fatalError("Upvote method not implemented.")
//					self.upVoteCompletion(self)
//					self.voteOnThread(as: .upVote)
				}
				let downvoteAction = UIAction(title: "Downvote the Thread", image: UIImage(systemName: "arrow.down.circle.fill")) { _ in
					fatalError("Downvote method not implemented.")
//					self.voteOnThread(as: .downVote, completion: self)
				}
				let replyAction = UIAction(title: "Reply to Thread", image: R.image.symbols.message_fill()) { _ in
					self.replyToThread(via: viewController)
				}

				menuElements.append(upvoteAction)
				menuElements.append(downvoteAction)
				menuElements.append(replyAction)
			}
		}

		var userMenuElements: [UIMenuElement] = []

		// Username action
		if let user = self.relationships.user.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: "Show " + username + "'s Profile", image: UIImage(systemName: "person.crop.circle.fill")) { _ in
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: "Share Thread", image: UIImage(systemName: "square.and.arrow.up")) { _ in
			self.openShareSheet(on: viewController)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report thread action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: "Report Thread", image: UIImage(systemName: "exclamationmark.circle.fill"), attributes: .destructive) { _ in
				self.reportThread()
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
		let shareText = "You should read \"\(self.attributes.title)\" via @KurozoraApp"

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
		Vote on the thread with the given vote.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a thread.
	*/
	func voteOnThread(as voteStatus: VoteStatus, completion completionHandler: @escaping (ForumsThread) -> Void) {
		WorkflowController.shared.isSignedIn {
			KService.voteOnThread(self.id, withVoteStatus: voteStatus) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let voteStatus):
					DispatchQueue.main.async {
						if voteStatus == .upVote {
							self.attributes.metrics.weight += 1
						} else if voteStatus == .downVote {
							self.attributes.metrics.weight -= 1
						}

						self.attributes.voteAction = voteStatus

						completionHandler(self)
					}
				case .failure: break
				}
			}
		}
	}

	/**
		Presents the reply view for the current thread.

		- Parameter viewController: The view controller initiating the action.
	*/
	func replyToThread(via viewController: UIViewController? = UIApplication.topViewController) {
		WorkflowController.shared.isSignedIn {
			let kCommentEditorViewController = R.storyboard.textEditor.kCommentEditorViewController()
			kCommentEditorViewController?.delegate = viewController as? KCommentEditorViewDelegate
			kCommentEditorViewController?.forumsThread = self

			let kurozoraNavigationController = KNavigationController.init(rootViewController: kCommentEditorViewController!)
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false

			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/**
		Presents the profile view for the thread poster.

		- Parameter viewController: The view controller initiaing the segue.
	*/
	func visitOriginalPosterProfile(from viewController: UIViewController? = UIApplication.topViewController) {
		guard let user = self.relationships.user.data.first else { return }

		if let profileViewController = R.storyboard.profile.profileTableViewController() {
			profileViewController.userID = user.id
			profileViewController.dismissButtonIsEnabled = true

			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
			viewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/// Sends a report of the selected thread to the mods.
	func reportThread() {
		WorkflowController.shared.isSignedIn {

		}
	}
}
