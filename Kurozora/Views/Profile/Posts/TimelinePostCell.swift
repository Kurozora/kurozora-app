//
//  FeedPostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FeedPostCell: BaseFeedPostCell {
	var feedPost: FeedPost! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		if let user = feedPost.relationships.user.data.first {
			// Username
			usernameLabel?.text = user.attributes.username

			// Profile Image
			profileImageView?.image = user.attributes.profileImage
		}

		// Post content
		postTextView?.text = feedPost.attributes.content

		// Date time
		dateTimeLabel?.text = feedPost.attributes.createdAt.timeAgo

		// Post
		postTextView?.text = feedPost.attributes.content

		// Likes
		let heartsCount = feedPost.attributes.heartsCount
		heartButton?.setTitle("\(heartsCount)", for: .normal)

		// Comments
		let replyCount = feedPost.attributes.replyCount
		heartButton?.setTitle("\(replyCount)", for: .normal)

		// ReShare
		let shareCount = feedPost.attributes.shareCount
		shareButton?.setTitle("\(shareCount)", for: .normal)

		// Other Username
//		if let otherUsername = posts?[indexPath.row]["other_username"].stringValue, !otherUsername.isEmpty {
//			otherUserNameLabel?.text = otherUsername
//
//			userSeparatorLabel?.isHidden = false
//			otherUserNameLabel?.isHidden = false
//		} else {
			otherUserNameLabel?.isHidden = true
			userSeparatorLabel?.isHidden = true
//		}
	}
}
