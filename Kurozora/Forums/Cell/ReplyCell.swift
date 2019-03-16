//
//  ReplyCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol ReplyCellDelegate: class {
	func replyCellSelectedUserProfile(replyCell: ReplyCell)
	func replyCellSelectedUpVoteButton(replyCell: ReplyCell)
	func replyCellSelectedDownVoteButton(replyCell: ReplyCell)
}

class ReplyCell: UITableViewCell {
	@IBOutlet weak var avatar: UIImageView!
	@IBOutlet weak var username: UILabel?
	@IBOutlet weak var dateTime: UILabel!
	@IBOutlet weak var upVoteCountLabel: UILabel!
	@IBOutlet weak var textContent: UILabel!
	@IBOutlet weak var upVoteButton: UIButton!
	@IBOutlet weak var downVoteButton: UIButton!

	weak var delegate: ReplyCellDelegate?
	var forumThreadElement: ForumThreadElement!
	var threadRepliesElement: ThreadRepliesElement? {
		didSet {
			setup()
		}
	}

//	class func registerNibFor(tableView: UITableView) {
//		let listNib = UINib(nibName: "ReplyCell", bundle: nil)
//		tableView.register(listNib, forCellReuseIdentifier: "ReplyTextCell")
//	}

	override func awakeFromNib() {
		super.awakeFromNib()

		do {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedUserProfile))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			avatar.addGestureRecognizer(gestureRecognizer)
		}

		if let username = username {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedUserProfile))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			username.addGestureRecognizer(gestureRecognizer)
		}
	}

	fileprivate func setup() {
		guard let threadRepliesElement = threadRepliesElement else { return }

		if let avatar = threadRepliesElement.user?.avatar, avatar != "" {
			let avatar = URL(string: avatar)
			let resource = ImageResource(downloadURL: avatar!)
			self.avatar.kf.indicatorType = .activity
			self.avatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			avatar.image = #imageLiteral(resourceName: "default_avatar")
		}

		username?.text = threadRepliesElement.user?.username
		dateTime.text = "·  \(Date.timeAgo(threadRepliesElement.postedAt)) ·  "
		textContent.text = threadRepliesElement.content

		if let score = threadRepliesElement.score {
			upVoteCountLabel.text = "\(score)\((score < 1000) ? "" : "K")"
		}

		if let locked = forumThreadElement.locked, locked {
			upVoteButton.isHidden = true
			upVoteButton.isUserInteractionEnabled = false
			downVoteButton.isHidden = true
			downVoteButton.isUserInteractionEnabled = false
		}
	}

	// MARK: - IBActions
	@objc func pressedUserProfile(sender: AnyObject) {
		delegate?.replyCellSelectedUserProfile(replyCell: self)
	}

	@IBAction func upvoteButtonPressed(_ sender: UIButton) {
		delegate?.replyCellSelectedUpVoteButton(replyCell: self)
		upVoteButton.animateBounce()
	}

	@IBAction func downVoteButtonPressed(_ sender: UIButton) {
		delegate?.replyCellSelectedDownVoteButton(replyCell: self)
		downVoteButton.animateBounce()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		textContent.preferredMaxLayoutWidth = textContent.frame.size.width
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		textContent.preferredMaxLayoutWidth = textContent.frame.size.width
	}
}
