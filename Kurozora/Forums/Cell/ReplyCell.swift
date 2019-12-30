//
//  ReplyCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ReplyCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.borderColor.rawValue
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			profileImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var usernameLabel: UILabel? {
		didSet {
			usernameLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			usernameLabel?.addGestureRecognizer(gestureRecognizer)
			usernameLabel?.isUserInteractionEnabled = true
		}
	}
	@IBOutlet weak var dateTimeButton: UIButton! {
		didSet {
			dateTimeButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			dateTimeButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var voteCountButton: UIButton! {
		didSet {
			voteCountButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			voteCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var contentTextView: UITextView! {
		didSet {
			contentTextView.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			contentTextView.textContainerInset = .zero
			contentTextView.textContainer.lineFragmentPadding = 0
		}
	}
	@IBOutlet weak var upvoteButton: UIButton! {
		didSet {
			upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var downvoteButton: UIButton! {
		didSet {
			downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var moreButton: UIButton! {
		didSet {
			moreButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	var threadViewController: ThreadTableViewController?
	var forumsThreadElement: ForumsThreadElement?
	var threadRepliesElement: ThreadRepliesElement? {
		didSet {
			configureCell()
		}
	}
	var previousVote = 0

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let threadRepliesElement = threadRepliesElement else { return }

		// Configure profile image
		if let profileImage = threadRepliesElement.userProfile?.profileImage {
			if let usernameInitials = threadRepliesElement.userProfile?.username?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: #imageLiteral(resourceName: "default_profile_image"))
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}

		// Configure username
		usernameLabel?.text = threadRepliesElement.userProfile?.username

		// Configure
		if let contentText = threadRepliesElement.content {
			contentTextView.text = contentText
		}

		// Set thread stats
		if let replyScore = threadRepliesElement.score {
			voteCountButton.setTitle("\((replyScore >= 1000) ? replyScore.kFormatted : replyScore.string) · ", for: .normal)
		}

		if let creationDate = threadRepliesElement.postedAt, !creationDate.isEmpty {
			dateTimeButton.setTitle(creationDate.timeAgo, for: .normal)
		}

		// Check if thread is locked
		if let locked = forumsThreadElement?.locked {
			isLocked(locked)
		}

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	/**
		Upvote or downvote a thread according to the given integer.

		- Parameter vote: The integer indicating whether to downvote or upvote a reply.  (0 = downvote, 1 = upvote)
	*/
	fileprivate func voteForReply(with vote: Int) {
		WorkflowController.shared.isSignedIn {
			guard let threadRepliesElement = self.threadRepliesElement else { return }
			guard var replyScore = threadRepliesElement.score else { return }

			KService.shared.vote(forReply: threadRepliesElement.id, vote: vote) { action in
				DispatchQueue.main.async {
					if action == 1 { // upvote
						replyScore += 1
						self.upvoteButton.tintColor = .kGreen
						self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					} else if action == 0 { // no vote
						self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
						self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					} else if action == -1 { // downvote
						replyScore -= 1
						self.downvoteButton.tintColor = .kLightRed
						self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					}

					self.voteCountButton.setTitle("\((replyScore >= 1000) ? replyScore.kFormatted : replyScore.string) · ", for: .normal)
				}
			}
		}
	}

	/// Sends a report of the selected reply to the mods.
	func reportThread() {
		WorkflowController.shared.isSignedIn {
		}
	}

	/// Presents the profile view for the thread poster.
	fileprivate func visitPosterProfilePage() {
		if let userID = threadRepliesElement?.userProfile?.id, userID != 0 {
			if let profileViewController = ProfileTableViewController.instantiateFromStoryboard() as? ProfileTableViewController {
				profileViewController.userID = userID
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
				if #available(iOS 13.0, macCatalyst 13.0, *) {
					threadViewController?.present(kurozoraNavigationController, animated: true, completion: nil)
				} else {
					threadViewController?.presentAsStork(kurozoraNavigationController, height: nil, showIndicator: false, showCloseButton: false)
				}
			}
		}
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.

		- Parameter locked: The boolean indicating whather to show or hide the element.
	*/
	fileprivate func isLocked(_ locked: Bool) {
		if locked {
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
		guard let threadViewController = threadViewController else { return }
		guard let threadRepliesElement = threadRepliesElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
		if User.isAdmin || User.isMod {
		}

		// Upvote, downvote and reply actions
		if let replyID = threadRepliesElement.id, let locked = forumsThreadElement?.locked, replyID != 0 && !locked {
			let upvoteAction = UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteForReply(with: 1)
			})
			let downvoteAction = UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteForReply(with: 0)
			})
//			let replyAction = UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
//				self.replyThread()
//			})

			upvoteAction.setValue(#imageLiteral(resourceName: "Symbols/arrow_up_circle_fill"), forKey: "image")
			upvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			downvoteAction.setValue(#imageLiteral(resourceName: "Symbols/arrow_down_circle_fill"), forKey: "image")
			downvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//			replyAction.setValue(#imageLiteral(resourceName: "Symbols/message_fill"), forKey: "image")
//			replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			action.addAction(upvoteAction)
			action.addAction(downvoteAction)
//			action.addAction(replyAction)
		}

		// Username action
		if let username = threadRepliesElement.userProfile?.username, !username.isEmpty {
			let userAction = UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			})
			userAction.setValue(#imageLiteral(resourceName: "Symbols/person_crop_circle_fill"), forKey: "image")
			userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.addAction(userAction)
		}

		// Share thread action
		let shareAction = UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			self.shareReply()
		})
		shareAction.setValue(#imageLiteral(resourceName: "Symbols/square_and_arrow_up_fill"), forKey: "image")
		shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(shareAction)

		// Report thread action
		let reportAction = UIAlertAction.init(title: "Report", style: .destructive, handler: { (_) in
			self.reportThread()
		})
		reportAction.setValue(#imageLiteral(resourceName: "Symbols/exclamationmark_circle_fill"), forKey: "image")
		reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(reportAction)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}

		if (threadViewController.navigationController?.visibleViewController as? UIAlertController) == nil {
			threadViewController.present(action, animated: true, completion: nil)
		}
	}

	/// Presents a share sheet to share the selected reply.
	func shareReply() {
		guard let threadViewController = threadViewController else { return }
		guard let threadRepliesElement = threadRepliesElement else { return }

		var shareText: [String] = [""]

		if let replyContent = threadRepliesElement.content, let posterUsername = threadRepliesElement.userProfile?.username {
			shareText = ["\"\(replyContent)\"-\(posterUsername)"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}
		threadViewController.present(activityVC, animated: true, completion: nil)
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
		previousVote = 1
		voteForReply(with: 1)
		sender.animateBounce()
	}

	@IBAction func downvoteButtonPressed(_ sender: UIButton) {
		previousVote = 0
		voteForReply(with: 0)
		sender.animateBounce()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		showActionList()
	}
}
