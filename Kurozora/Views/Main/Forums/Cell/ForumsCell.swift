//
//  ForumsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwiftyJSON

class ForumsCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var usernameButton: UIButton! {
		didSet {
			usernameButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var contentLabel: UILabel! {
		didSet {
			contentLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var byLabel: UILabel! {
		didSet {
			byLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var voteCountButton: UIButton! {
		didSet {
			voteCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			voteCountButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var commentCountButton: UIButton! {
		didSet {
			commentCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			commentCountButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var dateTimeButton: UIButton! {
		didSet {
			dateTimeButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			dateTimeButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var lockImageView: UIImageView!

	@IBOutlet weak var moreButton: KButton! {
		didSet {
			moreButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
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
	@IBOutlet weak var actionsStackView: UIStackView!
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	var forumsChildViewController: ForumsListViewController?
	var forumThreadsElement: ForumsThreadElement? {
		didSet {
			configureCell()
		}
	}
	var previousVote = 0

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let forumThreadsElement = forumThreadsElement else { return }

		// Set title label
		titleLabel.text = forumThreadsElement.title

		// Set content label
		contentLabel.text = forumThreadsElement.content

		// Set poster username label
		usernameButton.setTitle(forumThreadsElement.posterUsername, for: .normal)

		// Set thread stats
		if let voteCount = forumThreadsElement.voteCount {
			voteCountButton.setTitle("\((voteCount >= 1000) ? voteCount.kFormatted : voteCount.string) · ", for: .normal)
		}

		if let commentCount = forumThreadsElement.commentCount {
			commentCountButton.setTitle("\((commentCount >= 1000) ? commentCount.kFormatted : commentCount.string) · ", for: .normal)
		}

		if let creationDate = forumThreadsElement.creationDate, !creationDate.isEmpty {
			dateTimeButton.setTitle(creationDate.timeAgo, for: .normal)
		}

		// Thread vote status
		if let voteStatusInt = forumThreadsElement.currentUser?.likeAction {
			let voteStatus = VoteStatus(rawValue: voteStatusInt) ?? .noVote
			updateVoting(withVoteStatus: voteStatus)
		}

		// Check if thread is locked
		lockImageView.tintColor = .kLightRed
		if let locked = forumThreadsElement.locked {
			isLocked(locked)
		}

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	/**
		Upvote or downvote a thread according to the given integer.

		- Parameter vote: The integer indicating whether to downvote or upvote a thread.  (0 = downvote, 1 = upvote)
	*/
	fileprivate func voteForThread(with vote: Int) {
		guard let voteStatus = VoteStatus(rawValue: vote) else { return }
		guard let threadID = self.forumThreadsElement?.id else { return }

		WorkflowController.shared.isSignedIn {
			guard var threadScore = self.forumThreadsElement?.voteCount else { return }
			KService.voteOnThread(threadID, withVoteStatus: voteStatus) { result in
				switch result {
				case .success(let voteStatus):
					DispatchQueue.main.async {
						self.updateVoting(withVoteStatus: voteStatus)
						if voteStatus == .upVote {
							threadScore += 1
						} else if voteStatus == .downVote {
							threadScore -= 1
						}

						self.voteCountButton.setTitle("\((threadScore >= 1000) ? threadScore.kFormatted : threadScore.string) · ", for: .normal)
					}
				case .failure: break
				}
			}
		}
	}

	/// Presents the profile view for the thread poster.
	fileprivate func visitPosterProfilePage() {
		if let posterID = forumThreadsElement?.posterUserID, posterID != 0 {
			if let profileViewController = R.storyboard.profile.profileTableViewController() {
				profileViewController.userProfile = try? UserProfile(json: ["id": posterID])
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
				forumsChildViewController?.present(kurozoraNavigationController)
			}
		}
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.
		
		- Parameter lockStatus: The `LockStatus` value indicating whather to show or hide some views.
	*/
	fileprivate func isLocked(_ lockStatus: LockStatus) {
		forumThreadsElement?.locked = lockStatus
		if lockStatus == .locked {
			lockImageView.isHidden = false
			upvoteButton.isHidden = true
			downvoteButton.isHidden = true
			upvoteButton.isUserInteractionEnabled = false
			downvoteButton.isUserInteractionEnabled = false
		} else {
			lockImageView.isHidden = true
			upvoteButton.isHidden = false
			downvoteButton.isHidden = false
			upvoteButton.isUserInteractionEnabled = true
			downvoteButton.isUserInteractionEnabled = true
		}
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		guard let forumsChildViewController = self.forumsChildViewController else { return }
		guard let forumThreadsElement = forumThreadsElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
//		if User.isAdmin || User.isMod {
//			if let threadID = forumThreadsElement.id, let locked = forumThreadsElement.locked, threadID != 0 {
//				var lock = 0
//				var lockTitle = "Locked"
//
//				if !locked {
//					lock = 1
//					lockTitle = "Unlocked"
//				}
//
//				let lockAction = UIAlertAction.init(title: lockTitle, style: .default, handler: { (_) in
//					KurozoraKit.shared.lockThread(withID: threadID, lock: lock, withSuccess: { (locked) in
//						self.isLocked(locked)
//					})
//				})
//				lockAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//
//				if locked {
//					lockAction.setValue(R.image.symbols.lock_fill()!, forKey: "image")
//				} else {
//					lockAction.setValue(R.image.symbols.lock_open_fill()!, forKey: "image")
//				}
//
//				action.addAction(lockAction)
//			}
//		}

		// Upvote, downvote and reply actions
		if let threadID = forumThreadsElement.id, threadID != 0 && forumThreadsElement.locked == .unlocked {
			let upvoteAction = UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteForThread(with: 1)
			})
			let downvoteAction = UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteForThread(with: 0)
			})
			let replyAction = UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
				self.replyThread()
			})

			upvoteAction.setValue(R.image.symbols.arrow_up_circle_fill()!, forKey: "image")
			upvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			downvoteAction.setValue(R.image.symbols.arrow_down_circle_fill()!, forKey: "image")
			downvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			replyAction.setValue(R.image.symbols.message_fill()!, forKey: "image")
			replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			action.addAction(upvoteAction)
			action.addAction(downvoteAction)
			action.addAction(replyAction)
		}

		// Username action
		if let username = forumThreadsElement.posterUsername, !username.isEmpty {
			let userAction = UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			})
			userAction.setValue(R.image.symbols.person_crop_circle_fill()!, forKey: "image")
			userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.addAction(userAction)
		}

		// Share thread action
		let shareAction = UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			self.shareThread()
		})
		shareAction.setValue(R.image.symbols.square_and_arrow_up_fill()!, forKey: "image")
		shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(shareAction)

		// Report thread action
		let reportAction = UIAlertAction.init(title: "Report", style: .destructive, handler: { (_) in
			self.reportThread()
		})
		reportAction.setValue(R.image.symbols.exclamationmark_circle_fill()!, forKey: "image")
		reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(reportAction)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}

		if (forumsChildViewController.navigationController?.visibleViewController as? UIAlertController) == nil {
			forumsChildViewController.present(action, animated: true, completion: nil)
		}
	}

	/// Presents a share sheet to share the selected thread.
	func shareThread() {
		guard let threadID = forumThreadsElement?.id else { return }
		guard let forumsChildViewController = forumsChildViewController else { return }
		let threadUrl = "https://kurozora.app/thread/\(threadID)"
		var shareText: [Any] = [URL(string: threadUrl) ?? threadUrl, "You should read this thread via @KurozoraApp"]

		if let title = self.titleLabel.text, !title.isEmpty {
			shareText = [URL(string: threadUrl) ?? threadUrl, "You should read \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}
		forumsChildViewController.present(activityVC, animated: true, completion: nil)
	}

	/// Sends a report of the selected thread to the mods.
	func reportThread() {
		WorkflowController.shared.isSignedIn {
		}
	}

	/**
		Update the voting status of the thread.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a thread.
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

	/// Presents the reply view for the current thread.
	func replyThread() {
		WorkflowController.shared.isSignedIn {
			// TODO: - Add reply function here
		}
	}

	/// Shows the relevant options for the selected thread.
	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		showActionList()
	}

	// MARK: - IBActions
	@IBAction func usernameButtonPressed(_ sender: UIButton) {
		visitPosterProfilePage()
	}

	@IBAction func upvoteButtonAction(_ sender: UIButton) {
		previousVote = 1
		voteForThread(with: 1)
		upvoteButton.animateBounce()
	}

	@IBAction func downvoteButtonAction(_ sender: UIButton) {
		previousVote = 0
		voteForThread(with: 0)
		downvoteButton.animateBounce()
	}

	@IBAction func moreButtonAction(_ sender: UIButton) {
		showActionList()
	}
}
