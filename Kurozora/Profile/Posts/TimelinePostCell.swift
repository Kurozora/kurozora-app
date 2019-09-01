//
//  FeedPostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class FeedPostCell: BaseFeedPostCell {
	var feedPostElement: FeedPostElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let feedPostElement = feedPostElement else { return }

		// Username
		usernameLabel?.text = feedPostElement.posterUsername

		// Post content
		postTextView?.text = feedPostElement.content

		// Date time
		dateTimeLabel?.text = Date.timeAgo(feedPostElement.creationDate)

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
		if let profileImage = feedPostElement.profileImage, !profileImage.isEmpty {
			let profileImage = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImage!, cacheKey: "currentUserAvatar")
			profileImageView?.kf.indicatorType = .activity
			profileImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			profileImageView?.image = #imageLiteral(resourceName: "default_avatar")
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
