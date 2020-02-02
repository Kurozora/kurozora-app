//
//  BaseFeedPostsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BaseFeedPostCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView? {
		didSet {
			profileImageView?.theme_borderColor = KThemePicker.borderColor.rawValue
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
			postTextView?.text = "Feed post..."
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
