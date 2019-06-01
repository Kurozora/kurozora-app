//
//  ForumsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ForumsCellDelegate: class {
	func moreButtonPressed(cell: ForumsCell)
	func upVoteButtonPressed(cell: ForumsCell)
	func downVoteButtonPressed(cell: ForumsCell)
}

public class ForumsCell: UITableViewCell {
	weak var delegate: ForumsCellDelegate?
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.forumsCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var contentLabel: UILabel! {
		didSet {
			contentLabel.theme_textColor = KThemePicker.forumsCellContentTextColor.rawValue
		}
	}
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var lockLabel: UILabel!

	@IBOutlet weak var moreButton: UIButton!
	@IBOutlet weak var upVoteButton: UIButton!
	@IBOutlet weak var downVoteButton: UIButton!
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.forumsCellBackgroundColor.rawValue
		}
	}

	// MARK: - IBActions
	@IBAction func moreButtonAction(_ sender: UIButton) {
		actionList()
	}

	@IBAction func upVoteButtonAction(_ sender: UIButton) {
		vote(1)
		upVoteButton.animateBounce()
	}

	@IBAction func downVoteButtonAction(_ sender: UIButton) {
		vote(0)
		downVoteButton.animateBounce()
	}

	var forumThreadsElement: ForumThreadsElement? {
		didSet {
			setup()
		}
	}

	// MARK: - Functions
	fileprivate func setup() {
		guard let forumThreadsElement = forumThreadsElement else { return }

		// Set title label
		titleLabel.text = forumThreadsElement.title

		// Set content label
		contentLabel.text = forumThreadsElement.contentTeaser

		// Set information label
		if let threadScore = forumThreadsElement.score, let threadReplyCount = forumThreadsElement.replyCount, let creationDate = forumThreadsElement.creationDate, creationDate != "" {
			informationLabel.text = " \(threadScore) ·  \(threadReplyCount)\((threadReplyCount < 1000) ? "" : "K") ·  \(Date.timeAgo(creationDate))"
		}

		// Set lock label
		if let locked = forumThreadsElement.locked, locked == true {
			lockLabel.isHidden = false
			upVoteButton.isUserInteractionEnabled = false
			upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
			downVoteButton.isUserInteractionEnabled = false
			downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
		} else {
			lockLabel.isHidden = true
		}

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	// Upvote/Downvote a thread
	func vote(_ vote: Int) {
		guard let forumThreadsElement = forumThreadsElement else { return }

		Service.shared.vote(forThread: forumThreadsElement.id, vote: vote, withSuccess: { (action) in
			DispatchQueue.main.async {
				if action == 1 {
					self.upVoteButton.setTitleColor(#colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1), for: .normal)
					self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				} else if action == 0 {
					self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
					self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				} else if action == -1 {
					self.downVoteButton.setTitleColor(#colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1), for: .normal)
					self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				}
			}
		})
	}

	// Populate action list
	func actionList() {
//		guard let forumThreadsElement = forumThreadsElement else { return }
//		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//		// Mod and Admin features actions
//		if let isAdmin = User.isAdmin(), let isMod = User.isMod() {
//			if isAdmin || isMod {
//				if let threadID = forumThreadsElement.id, let locked = forumThreadsElement.locked, threadID != 0 {
//					var lock = 0
//					var lockTitle = "Unlock"
//
//					if !locked {
//						lock = 1
//						lockTitle = "Lock"
//					}
//
//					action.addAction(UIAlertAction.init(title: lockTitle, style: .default, handler: { (_) in
//						Service.shared.lockThread(withID: threadID, lock: lock, withSuccess: { (locked) in
//							if locked {
//								self.lockLabel.isHidden = false
//								self.upVoteButton.isUserInteractionEnabled = false
//								self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
//								self.downVoteButton.isUserInteractionEnabled = false
//								self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
//								forumThreadsElement.locked = true
//							} else {
//								self.lockLabel.isHidden = true
//								self.upVoteButton.isUserInteractionEnabled = true
//								self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//								self.downVoteButton.isUserInteractionEnabled = true
//								self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//								forumThreadsElement.locked = false
//							}
//						})
//					}))
//				}
//			}
//		}
//
//		// Upvote, downvote and reply actions
//		if let threadID = forumThreadsElement.id, let locked = forumThreadsElement.locked, threadID != 0 && !locked {
//			action.addAction(UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
//				self.vote(1)
//			}))
//			action.addAction(UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
//				self.vote(0)
//			}))
//			action.addAction(UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
//			}))
//		}
//
//		// Username action
//		if let username = forumThreadsElement.posterUsername, username != "" {
//			action.addAction(UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
//				if let posterId = forumThreadsElement.posterUserID, posterId != 0 {
//					let storyboard = UIStoryboard(name: "profile", bundle: nil)
//					let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
//					profileViewController?.otherUserID = posterId
//					let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController!)
//
//					self.present(kurozoraNavigationController, animated: true, completion: nil)
//				}
//			}))
//		}
//
//		// Share thread action
//		action.addAction(UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
//			var shareText: String!
//			guard let threadID = forumThreadsElement.id else { return }
//
//			if let title = self.titleLabel.text {
//				shareText = "https://kurozora.app/thread/\(threadID)\nYou should read \"\(title)\" via @KurozoraApp"
//			} else {
//				shareText = "https://kurozora.app/thread/\(threadID)\nYou should read this thread via @KurozoraApp"
//			}
//
//			let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
//
//			if let popoverController = activityVC.popoverPresentationController {
//				popoverController.sourceView = self.view
//				popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//				popoverController.permittedArrowDirections = []
//			}
//			self.present(activityVC, animated: true, completion: nil)
//
//		}))
//
//		// Report thread action
//		action.addAction(UIAlertAction.init(title: "Report", style: .default, handler: { (_) in
//		}))
//
//		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
//
//		action.view.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
//
//		//Present the controller
//		if let popoverController = action.popoverPresentationController {
//			popoverController.sourceView = self.view
//			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//			popoverController.permittedArrowDirections = []
//		}
//
//		if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
//			self.present(action, animated: true, completion: nil)
//		}
	}

	// Show cell options
	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		actionList()
	}
}
