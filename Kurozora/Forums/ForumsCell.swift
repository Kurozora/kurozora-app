//
//  ForumsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON

public class ForumsCell: UITableViewCell {
	@IBOutlet weak var posterUsernameButton: UIButton! {
		didSet {
			posterUsernameButton.theme_tintColor = KThemePicker.tintColor.rawValue
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
	@IBOutlet weak var lockLabel: UILabel!

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

	var forumsChildViewController: ForumsChildViewController?
	var forumThreadsElement: ForumThreadsElement? {
		didSet {
			setup()
		}
	}
	var previousVote = 0

	// MARK: - Functions
	fileprivate func setup() {
		guard let forumThreadsElement = forumThreadsElement else { return }

		// Set title label
		titleLabel.text = forumThreadsElement.title

		// Set content label
		contentLabel.text = forumThreadsElement.contentTeaser

		// Set poster username label
		posterUsernameButton.setTitle(forumThreadsElement.posterUsername, for: .normal)

		// Set thread stats
		if let threadScore = forumThreadsElement.score {
			voteCountButton.setTitle("\((threadScore >= 1000) ? threadScore.kFormatted : threadScore.string) · ", for: .normal)
		}

		if let threadReplyCount = forumThreadsElement.replyCount {
			commentCountButton.setTitle("\((threadReplyCount >= 1000) ? threadReplyCount.kFormatted : threadReplyCount.string) · ", for: .normal)
		}

		if let creationDate = forumThreadsElement.creationDate, creationDate != "" {
			dateTimeButton.setTitle("\(Date.timeAgo(creationDate))", for: .normal)
		}

		// Check if thread is locked
		if let locked = forumThreadsElement.locked {
			isLocked(locked)
		}

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	// Visit the poster's profile page
	fileprivate func visitPosterProfilePage() {
		if let posterId = forumThreadsElement?.posterUserID, posterId != 0 {
			let storyboard = UIStoryboard(name: "profile", bundle: nil)
			let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
			profileViewController?.otherUserID = posterId
			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController!)

			forumsChildViewController?.present(kurozoraNavigationController, animated: true, completion: nil)
		}
	}

	// Lock thread
	fileprivate func isLocked(_ locked: Bool) {
		forumThreadsElement?.locked = locked
		// Set lock label
		if locked {
			lockLabel.isHidden = false
			upvoteButton.isUserInteractionEnabled = false
			downvoteButton.isUserInteractionEnabled = false
			moreButton.isUserInteractionEnabled = false
			actionsStackView.isHidden = true
		} else {
			lockLabel.isHidden = true
			upvoteButton.isUserInteractionEnabled = true
			downvoteButton.isUserInteractionEnabled = true
			moreButton.isUserInteractionEnabled = true
			actionsStackView.isHidden = false
		}
	}

	// Upvote/Downvote a thread
	fileprivate func voteForThread(with vote: Int) {
		guard let forumThreadsElement = forumThreadsElement else { return }
		guard var threadScore = forumThreadsElement.score else { return }

		Service.shared.vote(forThread: forumThreadsElement.id, vote: vote, withSuccess: { (action) in
			DispatchQueue.main.async {
				if action == 1 { // upvote
					threadScore += 1
					self.upvoteButton.tintColor = #colorLiteral(red: 0.2156862745, green: 0.8274509804, blue: 0.1294117647, alpha: 1)
					self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				} else if action == 0 { // no vote
					self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				} else if action == -1 { // downvote
					threadScore -= 1
					self.downvoteButton.tintColor = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1)
					self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				}

				self.voteCountButton.setTitle("\((threadScore >= 1000) ? threadScore.kFormatted : threadScore.string) · ", for: .normal)
			}
		})
	}

	// Populate action list
	fileprivate func actionList() {
		guard let forumsChildViewController = self.forumsChildViewController else { return }
		guard let forumThreadsElement = forumThreadsElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
		if let isAdmin = User.isAdmin(), let isMod = User.isMod() {
			if isAdmin || isMod {
				if let threadID = forumThreadsElement.id, let locked = forumThreadsElement.locked, threadID != 0 {
					var lock = 0
					var lockTitle = "Unlock"

					if !locked {
						lock = 1
						lockTitle = "Lock"
					}

					action.addAction(UIAlertAction.init(title: lockTitle, style: .default, handler: { (_) in
						Service.shared.lockThread(withID: threadID, lock: lock, withSuccess: { (locked) in
							self.isLocked(locked)
						})
					}))
				}
			}
		}

		// Upvote, downvote and reply actions
		if let threadID = forumThreadsElement.id, let locked = forumThreadsElement.locked, threadID != 0 && !locked {
			action.addAction(UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteForThread(with: 1)
			}))
			action.addAction(UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteForThread(with: 0)
			}))
			action.addAction(UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
			}))
		}

		// Username action
		if let username = forumThreadsElement.posterUsername, username != "" {
			action.addAction(UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			}))
		}

		// Share thread action
		action.addAction(UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			var shareText: String!
			guard let threadID = forumThreadsElement.id else { return }

			if let title = self.titleLabel.text {
				shareText = "https://kurozora.app/thread/\(threadID)\nYou should read \"\(title)\" via @KurozoraApp"
			} else {
				shareText = "https://kurozora.app/thread/\(threadID)\nYou should read this thread via @KurozoraApp"
			}

			let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

			if let popoverController = activityVC.popoverPresentationController {
				popoverController.sourceView = forumsChildViewController.view
				popoverController.sourceRect = CGRect(x: forumsChildViewController.view.bounds.midX, y: forumsChildViewController.view.bounds.midY, width: 0, height: 0)
				popoverController.permittedArrowDirections = []
			}
			forumsChildViewController.present(activityVC, animated: true, completion: nil)
		}))

		// Report thread action
		action.addAction(UIAlertAction.init(title: "Report", style: .default, handler: { (_) in
		}))

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = forumsChildViewController.view
			popoverController.sourceRect = CGRect(x: forumsChildViewController.view.bounds.midX, y: forumsChildViewController.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		if !(forumsChildViewController.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
			forumsChildViewController.present(action, animated: true, completion: nil)
		}
	}

	// Show cell options
	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		actionList()
	}

	// MARK: - IBActions
	@IBAction func posterUsernameButtonPressed(_ sender: UIButton) {
		visitPosterProfilePage()
	}

	@IBAction func upVoteButtonAction(_ sender: UIButton) {
		previousVote = 1
		voteForThread(with: 1)
		upvoteButton.animateBounce()
	}

	@IBAction func downVoteButtonAction(_ sender: UIButton) {
		previousVote = 0
		voteForThread(with: 0)
		downvoteButton.animateBounce()
	}

	@IBAction func moreButtonAction(_ sender: UIButton) {
		actionList()
	}
}
