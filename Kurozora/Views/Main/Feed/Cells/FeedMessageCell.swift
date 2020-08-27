//
//  FeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FeedMessageCell: BaseFeedMessageCell {
	var feedMessage: FeedMessage! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		if let user = self.feedMessage.relationships.users.data.first {
			// Username
			usernameLabel?.text = user.attributes.username

			// Profile Image
			profileImageView?.image = user.attributes.profileImage
		}

		// Post content
		postTextView?.text = self.feedMessage.attributes.body

		// Date time
		dateTimeLabel?.text = self.feedMessage.attributes.createdAt.timeAgo

		// Likes
		let heartsCount = self.feedMessage.attributes.metrics.hearts
		heartButton?.setTitle("\(heartsCount)", for: .normal)

		// Comments
		let replyCount = self.feedMessage.attributes.replyCount
		heartButton?.setTitle("\(replyCount)", for: .normal)

		// ReShare
		let reShareCount = self.feedMessage.attributes.reShareCount
		shareButton?.setTitle("\(reShareCount)", for: .normal)
	}
}
