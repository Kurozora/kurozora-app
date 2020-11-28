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
}

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

	weak var delegate: ReplyCellDelegate?
	var forumsThread: ForumsThread!
	var threadReply: ThreadReply! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the tab bar item content view.
	fileprivate func sharedInit() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
	}

	/// Configure the cell with the given details.
	fileprivate func configureCell() {
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
	@objc func usernameLabelPressed(sender: AnyObject) {
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
		fatalError("More button not implementd.")
//		showActionList()
	}
}
