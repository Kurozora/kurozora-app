//
//  FeedPostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class BaseFeedPostCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView? {
		didSet {
			profileImageView?.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel? {
		didSet {
			usernameLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var userSeparatorLabel: UILabel? {
		didSet {
			userSeparatorLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var otherUserNameLabel: UILabel? {
		didSet {
			otherUserNameLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var dateTimeLabel: UILabel? {
		didSet {
			dateTimeLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var postTextView: UITextView? {
		didSet {
			postTextView?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var heartButton: UIButton? {
		didSet {
			heartButton?.theme_setTitleColor(KThemePicker.tableViewCellSubTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var commentButton: UIButton? {
		didSet {
			commentButton?.theme_setTitleColor(KThemePicker.tableViewCellSubTextColor.rawValue, forState: .normal)
			commentButton?.theme_tintColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var shareButton: UIButton? {
		didSet {
			shareButton?.theme_setTitleColor(KThemePicker.tableViewCellSubTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var moreButton: UIButton? {
		didSet {
			moreButton?.theme_tintColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	@IBOutlet weak var bubbleView: UIView? {
		didSet {
			bubbleView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
}

class FeedPostCell: BaseFeedPostCell {
	var feedPostsElement: FeedPostsElement? {
		didSet {
			setup()
		}
	}

	// MARK: - Functions
	fileprivate func setup() {
		guard let feedPostsElement = feedPostsElement else { return }

		usernameLabel?.text = feedPostsElement.posterUsername
		postTextView?.text = feedPostsElement.content
		dateTimeLabel?.text = Date.timeAgo(feedPostsElement.creationDate)

		if let heartsCount = feedPostsElement.heartsCount {
			heartButton?.setTitle(String(heartsCount), for: .normal)
		}

		if let replyCount = feedPostsElement.replyCount {
			heartButton?.setTitle(String(replyCount), for: .normal)
		}

		if let shareCount = feedPostsElement.shareCount {
			shareButton?.setTitle(String(shareCount), for: .normal)
		}
	}
}
