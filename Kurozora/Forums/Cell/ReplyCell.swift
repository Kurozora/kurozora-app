//
//  ReplyCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

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
