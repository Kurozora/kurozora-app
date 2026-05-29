//
//  PostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
	@IBOutlet weak public var profileImage: ProfileImageView!
	@IBOutlet weak public var profileBorderView: BorderView?
	@IBOutlet weak public var usernameLabel: UILabel?
	@IBOutlet weak public var dateTime: UILabel!

	@IBOutlet weak public var imageContent: UIImageView?
	@IBOutlet weak public var imageHeightConstraint: NSLayoutConstraint?
	@IBOutlet weak public var textContent: UILabel!

	@IBOutlet weak public var replyButton: UIButton!
	@IBOutlet weak public var heartButton: UIButton!
	@IBOutlet weak public var playButton: UIButton?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.profileImage.layer.borderWidth = 0
		self.profileBorderView?.cornerRadius = self.profileImage.bounds.height / 2.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.profileBorderView?.cornerRadius = self.profileImage.bounds.height / 2.0

		if let playButton = self.playButton {
			playButton.layerCornerRadius = playButton.frame.size.height / 2.0
		}
	}

	// MARK: - IBActions
	@IBAction func replyPressed(sender: AnyObject) {
		replyButton.animateBounce()
	}

	@IBAction func heartPressed(sender: AnyObject) {
		heartButton.animateBounce()
	}
}
