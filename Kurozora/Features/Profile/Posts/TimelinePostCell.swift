//
//  FeedPostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FeedPostCell: BaseFeedPostCell {
	var feedPostElement: FeedPostElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let feedPostElement = feedPostElement else { return }

		// Username
		usernameLabel?.text = feedPostElement.posterUsername

		// Post content
		postTextView?.text = feedPostElement.content

		// Date time
		dateTimeLabel?.text = feedPostElement.creationDate?.timeAgo

		// Post
		if let postText = feedPostElement.content {
			postTextView?.text = postText
		}

		// Likes
		if let heartsCount = feedPostElement.heartsCount {
			heartButton?.setTitle(String(heartsCount), for: .normal)
		}
		// Comments
		if let replyCount = feedPostElement.replyCount {
			heartButton?.setTitle(String(replyCount), for: .normal)
		}

		// ReShare
		if let shareCount = feedPostElement.shareCount {
			shareButton?.setTitle(String(shareCount), for: .normal)
		}

		// Profile Image
		if let profileImage = feedPostElement.profileImage {
			if let usernameInitials = feedPostElement.posterUsername?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholder.profile_image()!)
				profileImageView?.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}

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
