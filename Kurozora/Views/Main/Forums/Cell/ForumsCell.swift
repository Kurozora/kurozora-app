//
//  ForumsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ForumsCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var usernameButton: KButton!
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
	@IBOutlet weak var voteCountButton: CellActionButton!
	@IBOutlet weak var commentCountButton: CellActionButton!
	@IBOutlet weak var dateTimeButton: CellActionButton!
	@IBOutlet weak var lockImageView: UIImageView!

	@IBOutlet weak var moreButton: CellActionButton!
	@IBOutlet weak var upvoteButton: CellActionButton!
	@IBOutlet weak var downvoteButton: CellActionButton!
	@IBOutlet weak var actionsStackView: UIStackView!
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	var forumsChildViewController: ForumsListViewController?
	var forumsThread: ForumsThread! {
		didSet {
			configureCell()
		}
	}
	var previousVote = 0

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		// Set title label
		titleLabel.text = forumsThread.attributes.title

		// Set content label
		contentLabel.text = forumsThread.attributes.content

		// Set poster username label
		if let user = forumsThread.relationships.user.data.first {
			usernameButton.setTitle(user.attributes.username, for: .normal)
		}

		// Set thread stats
		let voteCount = forumsThread.attributes.metrics.weight
		voteCountButton.setTitle("\(voteCount.kkFormatted) · ", for: .normal)

		let replyCount = forumsThread.attributes.replyCount
		commentCountButton.setTitle("\(replyCount.kkFormatted) · ", for: .normal)

		dateTimeButton.setTitle(forumsThread.attributes.createdAt.timeAgo, for: .normal)

		// Thread vote status
		self.updateVoting(withVoteStatus: forumsThread.attributes.voteAction)

		// Check if thread is locked
		lockImageView.tintColor = .kLightRed
		let lockStatus = forumsThread.attributes.lockStatus
		isLocked(lockStatus)

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	/**
		Vote on the thread with the given vote.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a thread.
	*/
	fileprivate func voteOnThread(withVoteStatus voteStatus: VoteStatus) {
		WorkflowController.shared.isSignedIn {
			KService.voteOnThread(self.forumsThread.id, withVoteStatus: voteStatus) { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success(let voteStatus):
					DispatchQueue.main.async {
						var threadScore = self.forumsThread.attributes.metrics.weight

						self.updateVoting(withVoteStatus: voteStatus)
						if voteStatus == .upVote {
							threadScore += 1
						} else if voteStatus == .downVote {
							threadScore -= 1
						}

						self.voteCountButton.setTitle("\(threadScore.kkFormatted) · ", for: .normal)
					}
				case .failure: break
				}
			}
		}
	}

	/// Presents the profile view for the thread poster.
	fileprivate func visitPosterProfilePage() {
		guard let user = forumsThread.relationships.user.data.first else { return }

		if let profileViewController = R.storyboard.profile.profileTableViewController() {
			profileViewController.userID = user.id
			profileViewController.dismissButtonIsEnabled = true

			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
			forumsChildViewController?.present(kurozoraNavigationController, animated: true)
		}
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.
		
		- Parameter lockStatus: The `LockStatus` value indicating whather to show or hide some views.
	*/
	fileprivate func isLocked(_ lockStatus: LockStatus) {
		// Set lock label
		switch lockStatus {
		case .locked:
			lockImageView.isHidden = false
			upvoteButton.isHidden = true
			downvoteButton.isHidden = true
			upvoteButton.isUserInteractionEnabled = false
			downvoteButton.isUserInteractionEnabled = false
		case .unlocked:
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
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Upvote, downvote and reply actions
		if forumsThread.attributes.lockStatus == .unlocked {
			let upvoteAction = UIAlertAction(title: "Upvote", style: .default, handler: { _ in
				self.voteOnThread(withVoteStatus: .upVote)
			})
			let downvoteAction = UIAlertAction(title: "Downvote", style: .default, handler: { _ in
				self.voteOnThread(withVoteStatus: .downVote)
			})
			let replyAction = UIAlertAction(title: "Reply", style: .default, handler: { _ in
				self.replyThread()
			})

			upvoteAction.setValue(R.image.symbols.arrow_up_circle_fill()!, forKey: "image")
			upvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			downvoteAction.setValue(R.image.symbols.arrow_down_circle_fill()!, forKey: "image")
			downvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			replyAction.setValue(R.image.symbols.message_fill()!, forKey: "image")
			replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			alertController.addAction(upvoteAction)
			alertController.addAction(downvoteAction)
			alertController.addAction(replyAction)
		}

		// Username action
		if let user = forumsThread.relationships.user.data.first {
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
			self.shareThread()
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

		if (forumsChildViewController.navigationController?.visibleViewController as? UIAlertController) == nil {
			forumsChildViewController.present(alertController, animated: true, completion: nil)
		}
	}

	/// Presents a share sheet to share the selected thread.
	func shareThread() {
		guard let forumsChildViewController = forumsChildViewController else { return }
		let threadURLString = "https://kurozora.app/thread/\(forumsThread.id)"
		let threadURL: Any = URL(string: threadURLString) ?? threadURLString
		let shareText = "You should read \"\(forumsThread.attributes.title)\" via @KurozoraApp"

		let activityItems: [Any] = [threadURL, shareText]
		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}
		forumsChildViewController.present(activityViewController, animated: true, completion: nil)
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
			let kCommentEditorViewController = R.storyboard.textEditor.kCommentEditorViewController()
			kCommentEditorViewController?.forumsThread = self.forumsThread

			let kurozoraNavigationController = KNavigationController.init(rootViewController: kCommentEditorViewController!)
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false

			self.parentViewController?.present(kurozoraNavigationController, animated: true)
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
		voteOnThread(withVoteStatus: .upVote)
		upvoteButton.animateBounce()
	}

	@IBAction func downvoteButtonAction(_ sender: UIButton) {
		previousVote = 0
		voteOnThread(withVoteStatus: .downVote)
		downvoteButton.animateBounce()
	}

	@IBAction func moreButtonAction(_ sender: UIButton) {
		showActionList()
	}
}
