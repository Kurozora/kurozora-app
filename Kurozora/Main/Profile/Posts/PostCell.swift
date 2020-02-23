//
//  PostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

@objc protocol PostCellDelegate: class {
	@objc optional func postCellSelectedImage(postCell: PostCell)
	func postCellSelectedUserProfile(postCell: PostCell)
	@objc optional func postCellSelectedToUserProfile(postCell: PostCell)
	func postCellSelectedComment(postCell: PostCell)
	func postCellSelectedHeart(postCell: PostCell)
}

class PostCell: UITableViewCell {
	@IBOutlet weak public var profileImage: UIImageView!
	@IBOutlet weak public var usernameLabel: UILabel?
	@IBOutlet weak public var dateTime: UILabel!

	@IBOutlet weak public var toIcon: UILabel?
	@IBOutlet weak public var toUsername: UILabel?

	@IBOutlet weak public var imageContent: UIImageView?
	@IBOutlet weak public var imageHeightConstraint: NSLayoutConstraint?
	@IBOutlet weak public var textContent: UILabel!

	@IBOutlet weak public var replyButton: UIButton!
	@IBOutlet weak public var heartButton: UIButton!
	@IBOutlet weak public var playButton: UIButton?

	weak var delegate: PostCellDelegate?

	class func registerNibFor(tableView: UITableView) {
		let listNib = UINib(nibName: "PostTextCell", bundle: nil)
		tableView.register(listNib, forCellReuseIdentifier: "PostTextCell")
		tableView.register(R.nib.postImageCell)

	}

	override func awakeFromNib() {
		super.awakeFromNib()

		do {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			profileImage.addGestureRecognizer(gestureRecognizer)
		}

		if let imageContent = imageContent {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImagePressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			imageContent.addGestureRecognizer(gestureRecognizer)
		}

		if let username = usernameLabel {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			username.addGestureRecognizer(gestureRecognizer)
		}

		if let toUsername = toUsername {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedToUserProfile))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			toUsername.addGestureRecognizer(gestureRecognizer)
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		textContent.preferredMaxLayoutWidth = textContent.frame.size.width
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		textContent.preferredMaxLayoutWidth = textContent.frame.size.width
	}

	// MARK: - IBActions
	@objc func usernameLabelPressed(sender: AnyObject) {
		delegate?.postCellSelectedUserProfile(postCell: self)
	}

	@objc func pressedToUserProfile(sender: AnyObject) {
		delegate?.postCellSelectedToUserProfile?(postCell: self)
	}

	@objc func profileImagePressed(sender: AnyObject) {
		delegate?.postCellSelectedImage?(postCell: self)
	}

	@IBAction func replyPressed(sender: AnyObject) {
		delegate?.postCellSelectedComment(postCell: self)
		replyButton.animateBounce()
	}

	@IBAction func heartPressed(sender: AnyObject) {
		delegate?.postCellSelectedHeart(postCell: self)
		heartButton.animateBounce()
	}
}
