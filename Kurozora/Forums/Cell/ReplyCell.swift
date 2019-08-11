//
//  ReplyCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class ReplyCell: UITableViewCell {
	@IBOutlet weak var avatarImageView: UIImageView! {
		didSet {
			avatarImageView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedUserProfile))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			avatarImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var usernameLabel: UILabel? {
		didSet {
			usernameLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedUserProfile))
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
	@IBOutlet weak var voteCountButton: UIButton!{
		didSet {
			voteCountButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			voteCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var interpunctLabel: UILabel! {
		didSet {
			interpunctLabel.theme_textColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var replyLabel: UILabel! {
		didSet {
			replyLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
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

	var threadViewController: ThreadViewController?
	var forumThreadElement: ForumThreadElement?
	var threadRepliesElement: ThreadRepliesElement? {
		didSet {
			configureCell()
		}
	}
	var previousVote = 0

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let threadRepliesElement = threadRepliesElement else { return }

		if let avatar = threadRepliesElement.user?.avatar, avatar != "" {
			let avatar = URL(string: avatar)
			let resource = ImageResource(downloadURL: avatar!)
			self.avatarImageView.kf.indicatorType = .activity
			self.avatarImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			avatarImageView.image = #imageLiteral(resourceName: "default_avatar")
		}

		usernameLabel?.text = threadRepliesElement.user?.username
		replyLabel.text = threadRepliesElement.content

		// Set thread stats
		if let replyScore = threadRepliesElement.score {
			voteCountButton.setTitle("\((replyScore >= 1000) ? replyScore.kFormatted : replyScore.string) · ", for: .normal)
		}

		if let creationDate = threadRepliesElement.postedAt, creationDate != "" {
			dateTimeButton.setTitle("\(Date.timeAgo(creationDate))", for: .normal)
		}


		// Check if thread is locked
		if let locked = forumThreadElement?.locked {
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
		guard let threadRepliesElement = threadRepliesElement else { return }
		guard var replyScore = threadRepliesElement.score else { return }

		Service.shared.vote(forReply: threadRepliesElement.id, vote: vote) { action in
			DispatchQueue.main.async {
				if action == 1 { // upvote
					replyScore += 1
					self.voteCountButton.setImage(#imageLiteral(resourceName: "arrow_up_small"), for: .normal)
					self.voteCountButton.setTitleColor(#colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1), for: .normal)
					self.voteCountButton.tintColor = #colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1)

					self.upvoteButton.tintColor = #colorLiteral(red: 0.2156862745, green: 0.8274509804, blue: 0.1294117647, alpha: 1)
					self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				} else if action == 0 { // no vote
					self.voteCountButton.setImage(#imageLiteral(resourceName: "arrow_up_small"), for: .normal)
					self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				} else if action == -1 { // downvote
					replyScore -= 1
					self.voteCountButton.setImage(#imageLiteral(resourceName: "arrow_down_small"), for: .normal)
					self.voteCountButton.setTitleColor(#colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1), for: .normal)
					self.voteCountButton.tintColor = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1)

					self.downvoteButton.tintColor = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1)
					self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				}

				self.voteCountButton.setTitle("\((replyScore >= 1000) ? replyScore.kFormatted : replyScore.string) · ", for: .normal)
			}
		}
	}

	// Visit the poster's profile page
	fileprivate func visitPosterProfilePage() {
		if let posterId = threadRepliesElement?.user?.id, posterId != 0 {
			let storyboard = UIStoryboard(name: "profile", bundle: nil)
			let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController
			profileViewController?.otherUserID = posterId
			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController!)

			if #available(iOS 13.0, *) {
				threadViewController?.present(kurozoraNavigationController, animated: true, completion: nil)
			} else {
				threadViewController?.presentAsStork(kurozoraNavigationController, height: nil, showIndicator: false, showCloseButton: false)
			}
		}
	}

	// Lock thread
	fileprivate func isLocked(_ locked: Bool) {
		// Set lock label
		if locked {
			upvoteButton.isHidden = true
			upvoteButton.isUserInteractionEnabled = false

			downvoteButton.isHidden = true
			downvoteButton.isUserInteractionEnabled = false
		} else {
			upvoteButton.isHidden = false
			upvoteButton.isUserInteractionEnabled = true

			downvoteButton.isHidden = false
			downvoteButton.isUserInteractionEnabled = true
		}
	}

	// Populate action list
	fileprivate func actionList() {
		guard let threadViewController = threadViewController else { return }
		guard let threadRepliesElement = threadRepliesElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
		if User.isAdmin || User.isMod {
		}

		// Upvote, downvote and reply actions
		if let replyID = threadRepliesElement.id, let locked = forumThreadElement?.locked, replyID != 0 && !locked {
			action.addAction(UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteForReply(with: 1)
			}))
			action.addAction(UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteForReply(with: 0)
			}))
//			action.addAction(UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
//			}))
		}

		// Username action
		if let username = threadRepliesElement.user?.username, username != "" {
			action.addAction(UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			}))
		}

		// Share thread action
		action.addAction(UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			var shareText = ""

			if let title = self.replyLabel.text {
				shareText = title
			}

			let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

			if let popoverController = activityVC.popoverPresentationController {
				popoverController.sourceView = threadViewController.view
				popoverController.sourceRect = CGRect(x: threadViewController.view.bounds.midX, y: threadViewController.view.bounds.midY, width: 0, height: 0)
				popoverController.permittedArrowDirections = []
			}
			threadViewController.present(activityVC, animated: true, completion: nil)
		}))

		// Report thread action
		action.addAction(UIAlertAction.init(title: "Report", style: .default, handler: { (_) in
		}))

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = threadViewController.view
			popoverController.sourceRect = CGRect(x: threadViewController.view.bounds.midX, y: threadViewController.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		if !(threadViewController.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
			threadViewController.present(action, animated: true, completion: nil)
		}
	}

	// Show cell options
	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		actionList()
	}

	// MARK: - IBActions
	@objc func pressedUserProfile(sender: AnyObject) {
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
		actionList()
	}

//	override func layoutSubviews() {
//		super.layoutSubviews()
//		replyLabel.preferredMaxLayoutWidth = textContent.frame.size.width
//	}
//
//	override func prepareForReuse() {
//		super.prepareForReuse()
//		textContent.preferredMaxLayoutWidth = textContent.frame.size.width
//	}
}
