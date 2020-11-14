//
//  ReplyCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ReplyCell: UITableViewCell {
	@IBOutlet weak var profileImageView: ProfileImageView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			profileImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			usernameLabel.addGestureRecognizer(gestureRecognizer)
			usernameLabel.isUserInteractionEnabled = true
		}
	}
	@IBOutlet weak var dateTimeButton: CellActionButton!
	@IBOutlet weak var voteCountButton: CellActionButton!
	@IBOutlet weak var contentTextView: KTextView! {
		didSet {
			contentTextView.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var upvoteButton: CellActionButton!
	@IBOutlet weak var downvoteButton: CellActionButton!
	@IBOutlet weak var moreButton: CellActionButton!
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	var threadViewController: ThreadTableViewController!
	var forumsThread: ForumsThread!
	var threadReply: ThreadReply! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		if let user = threadReply.relationships.user.data.first {
			// Configure username
			usernameLabel.text = user.attributes.username

			// Configure profile image
			profileImageView.image = user.attributes.profileImage
		}

		// Configure
		contentTextView.text = threadReply.attributes.content

		// Set thread stats
		let replyScore = threadReply.attributes.metrics.weight
		voteCountButton.setTitle("\(replyScore.kkFormatted) · ", for: .normal)

		dateTimeButton.setTitle(threadReply.attributes.createdAt.timeAgo, for: .normal)

		// Thread reply vote status
		self.updateVoting(withVoteStatus: threadReply.attributes.voteAction)

		// Check if thread is locked
		isLocked(forumsThread.attributes.lockStatus)

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	/**
		Vote on the reply with the given vote.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a reply.
	*/
	fileprivate func voteOnReply(withVoteStatus voteStatus: VoteStatus) {
		WorkflowController.shared.isSignedIn {
			KService.voteOnReply(self.threadReply.id, withVoteStatus: voteStatus) { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success(let voteStatus):
					DispatchQueue.main.async {
						var replyScore = self.threadReply.attributes.metrics.weight

						self.updateVoting(withVoteStatus: voteStatus)
						if voteStatus == .upVote {
							replyScore += 1
						} else if voteStatus == .downVote {
							replyScore -= 1
						}

						self.voteCountButton.setTitle("\(replyScore.kkFormatted) · ", for: .normal)
					}
				case .failure: break
				}
			}
		}
	}

	/// Sends a report of the selected reply to the mods.
	func reportThread() {
		WorkflowController.shared.isSignedIn {
		}
	}

	/**
		Update the voting status of the reply.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a reply.
	*/
	fileprivate func updateVoting(withVoteStatus voteStatus: VoteStatus) {
		if voteStatus == .upVote {
			self.upvoteButton.tintColor = .kGreen
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		} else if voteStatus == .noVote {
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		} else if voteStatus == .downVote {
			self.downvoteButton.tintColor = .kLightRed
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/// Presents the profile view for the thread poster.
	fileprivate func visitPosterProfilePage() {
		if let user = threadReply.relationships.user.data.first {
			if let profileViewController = R.storyboard.profile.profileTableViewController() {
				profileViewController.userID = user.id
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)

				self.threadViewController.present(kurozoraNavigationController, animated: true)
			}
		}
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.

		- Parameter lockStatus: The `LockStatus` value indicating whather to show or hide some views.
	*/
	fileprivate func isLocked(_ lockStatus: LockStatus) {
		if lockStatus == .locked {
			upvoteButton.isHidden = true
			downvoteButton.isHidden = true
			upvoteButton.isUserInteractionEnabled = false
			downvoteButton.isUserInteractionEnabled = false
		} else {
			upvoteButton.isHidden = false
			downvoteButton.isHidden = false
			upvoteButton.isUserInteractionEnabled = true
			downvoteButton.isUserInteractionEnabled = true
		}
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions

		// Upvote, downvote and reply actions
		if forumsThread.attributes.lockStatus == .unlocked {
			let upvoteAction = UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteOnReply(withVoteStatus: .upVote)
			})
			let downvoteAction = UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteOnReply(withVoteStatus: .downVote)
			})
//			let replyAction = UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
//				self.replyThread()
//			})

			upvoteAction.setValue(R.image.symbols.arrow_up_circle_fill()!, forKey: "image")
			upvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			downvoteAction.setValue(R.image.symbols.arrow_down_circle_fill()!, forKey: "image")
			downvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//			replyAction.setValue(R.image.symbols.message_fill()!, forKey: "image")
//			replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			alertController.addAction(upvoteAction)
			alertController.addAction(downvoteAction)
//			alertController.addAction(replyAction)
		}

		// Username action
		if let user = threadReply.relationships.user.data.first {
			let username = user.attributes.username
			let userAction = UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			})
			userAction.setValue(R.image.symbols.person_crop_circle_fill()!, forKey: "image")
			userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			alertController.addAction(userAction)
		}

		// Share thread action
		let shareAction = UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			self.shareReply()
		})
		shareAction.setValue(R.image.symbols.square_and_arrow_up_fill()!, forKey: "image")
		shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		alertController.addAction(shareAction)

		// Report thread action
		let reportAction = UIAlertAction.init(title: "Report", style: .destructive, handler: { (_) in
			self.reportThread()
		})
		reportAction.setValue(R.image.symbols.exclamationmark_circle_fill()!, forKey: "image")
		reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		alertController.addAction(reportAction)

		alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}

		if (threadViewController.navigationController?.visibleViewController as? UIAlertController) == nil {
			threadViewController.present(alertController, animated: true, completion: nil)
		}
	}

	/// Presents a share sheet to share the selected reply.
	func shareReply() {
		var shareText = "\"\(threadReply.attributes.content)\""
		if let user = threadReply.relationships.user.data.first {
			shareText += "-\(user.attributes.username)"
		}

		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}
		threadViewController.present(activityViewController, animated: true, completion: nil)
	}

	/// Shows the relevant options for the selected reply.
	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		showActionList()
	}

	// MARK: - IBActions
	@objc func usernameLabelPressed(sender: AnyObject) {
		visitPosterProfilePage()
	}

	@IBAction func upvoteButtonPressed(_ sender: UIButton) {
		voteOnReply(withVoteStatus: .upVote)
		sender.animateBounce()
	}

	@IBAction func downvoteButtonPressed(_ sender: UIButton) {
		voteOnReply(withVoteStatus: .downVote)
		sender.animateBounce()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		showActionList()
	}
}
