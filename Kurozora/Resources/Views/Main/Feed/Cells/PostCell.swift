//
//  PostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
	@IBOutlet weak public var profileImage: UIImageView!
	@IBOutlet weak public var usernameLabel: UILabel?
	@IBOutlet weak public var dateTime: UILabel!

	@IBOutlet weak public var imageContent: UIImageView?
	@IBOutlet weak public var imageHeightConstraint: NSLayoutConstraint?
	@IBOutlet weak public var textContent: UILabel!

	@IBOutlet weak public var replyButton: UIButton!
	@IBOutlet weak public var heartButton: UIButton!
	@IBOutlet weak public var playButton: UIButton?

	// MARK: - IBActions
	@IBAction func replyPressed(sender: AnyObject) {
		replyButton.animateBounce()
	}

	@IBAction func heartPressed(sender: AnyObject) {
		heartButton.animateBounce()
	}
}
