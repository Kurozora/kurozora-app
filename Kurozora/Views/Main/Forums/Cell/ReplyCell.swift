//
//  ReplyCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ReplyCellDelegate: class {
	func voteOnReplyCell(_ cell: ReplyCell, with voteStatus: VoteStatus)
	func visitOriginalPosterProfile(_ cell: ReplyCell)
	func showActionsList(_ cell: ReplyCell, sender: UIButton)
}

class ReplyCell: KTableViewCell {
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var dateTimeButton: CellActionButton!
	@IBOutlet weak var voteCountButton: CellActionButton!
	@IBOutlet weak var contentTextView: KTextView!
	@IBOutlet weak var upvoteButton: CellActionButton!
	@IBOutlet weak var downvoteButton: CellActionButton!
	@IBOutlet weak var moreButton: CellActionButton!

	weak var delegate: ReplyCellDelegate?
	var forumsThread: ForumsThread!
	var threadReply: ThreadReply! {
		didSet {
			configureCell()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		profileImageView.addGestureRecognizer(self.profileSegueGestureRecognizer())
		usernameLabel.addGestureRecognizer(self.profileSegueGestureRecognizer())
		usernameLabel.isUserInteractionEnabled = true
	}

	// MARK: - Functions
	override func configureCell() {
		if let user = threadReply.relationships.users.data.first {
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
	}

	/**
		Returns a gesture recognizer for profile segue.

		- Returns: a gesture recognizer for profile segue.
	*/
	fileprivate func profileSegueGestureRecognizer() -> UIGestureRecognizer {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleProfileSegue(_:)))
		tapGestureRecognizer.numberOfTouchesRequired = 1
		tapGestureRecognizer.numberOfTapsRequired = 1
		return tapGestureRecognizer
	}

	/**
		Update the voting status of the reply.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a reply.
	*/
	fileprivate func updateVoting(withVoteStatus voteStatus: VoteStatus) {
		if voteStatus == .upVote {
			self.upvoteButton.tintColor = .kGreen
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.downvoteButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		} else if voteStatus == .noVote {
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.downvoteButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)

			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.upvoteButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		} else if voteStatus == .downVote {
			self.downvoteButton.tintColor = .kLightRed
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.upvoteButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
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

	// MARK: - IBActions
	@objc func handleProfileSegue(_ gestureRecognizer: UIGestureRecognizer) {
		self.delegate?.visitOriginalPosterProfile(self)
	}

	@IBAction func upvoteButtonPressed(_ sender: UIButton) {
		self.delegate?.voteOnReplyCell(self, with: .upVote)
		sender.animateBounce()
	}

	@IBAction func downvoteButtonPressed(_ sender: UIButton) {
		self.delegate?.voteOnReplyCell(self, with: .downVote)
		sender.animateBounce()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.showActionsList(self, sender: sender)
		sender.animateBounce()
	}
}
