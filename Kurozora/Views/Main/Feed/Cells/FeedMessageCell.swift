//
//  FeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FeedMessageCell: BaseFeedMessageCell {
	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		if let user = self.feedMessage.relationships.users.data.first {
			// Username
			usernameLabel.text = user.attributes.username

			// Profile Image
			profileImageView.image = user.attributes.profileImage
		}

		// Post content
		postTextView.text = self.feedMessage.attributes.body

		// Date time
		dateTimeLabel.text = self.feedMessage.attributes.createdAt.timeAgo

		// Hearts
		let heartsCount = self.feedMessage.attributes.metrics.heartCount
		heartButton.setTitle("\((heartsCount >= 1000) ? heartsCount.kFormatted : heartsCount.string)", for: .normal)

		// Replies
		let replyCount = self.feedMessage.attributes.metrics.replyCount
		commentButton.setTitle("\((replyCount >= 1000) ? replyCount.kFormatted : replyCount.string)", for: .normal)

		// ReShares
		let reShareCount = self.feedMessage.attributes.metrics.reShareCount
		shareButton.setTitle("\((reShareCount >= 1000) ? reShareCount.kFormatted : reShareCount.string)", for: .normal)
	}
}
