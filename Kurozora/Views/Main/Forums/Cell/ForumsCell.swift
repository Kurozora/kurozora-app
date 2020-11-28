//
//  ForumsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ForumsCellDelegate: class {
	func voteOnForumsCell(_ cell: ForumsCell, with voteStatus: VoteStatus)
	func visitOriginalPosterProfile(_ cell: ForumsCell)
}

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

	// MARK: - Properties
	weak var forumsCellDelegate: ForumsCellDelegate?
	var forumsThread: ForumsThread! {
		didSet {
			configureCell()
		}
	}
	var previousVote = 0

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
		// Set title label
		titleLabel.text = forumsThread.attributes.title

		// Set content label
		contentLabel.text = forumsThread.attributes.content

		// Set poster username label
		if let user = forumsThread.relationships.users.data.first {
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

	/**
		Update the voting status of the thread.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a thread.
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

	// MARK: - IBActions
	@IBAction func usernameButtonPressed(_ sender: UIButton) {
		self.forumsCellDelegate?.visitOriginalPosterProfile(self)
	}

	@IBAction func upvoteButtonAction(_ sender: UIButton) {
		self.previousVote = 1
		self.forumsCellDelegate?.voteOnForumsCell(self, with: .upVote)
		self.upvoteButton.animateBounce()
	}

	@IBAction func downvoteButtonAction(_ sender: UIButton) {
		self.previousVote = 0
		self.forumsCellDelegate?.voteOnForumsCell(self, with: .downVote)
		self.downvoteButton.animateBounce()
	}

	@IBAction func moreButtonAction(_ sender: UIButton) {
		fatalError("More button not implemented.")
//		showActionList()
	}
}
