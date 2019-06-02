//
//  TimelinePostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class TimelinePostCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var userNameLabel: UILabel! {
		didSet {
			userNameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var userSeparatorLabel: UILabel! {
		didSet {
			userSeparatorLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var otherUserNameLabel: UILabel! {
		didSet {
			otherUserNameLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var dateTimeLabel: UILabel! {
		didSet {
			dateTimeLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var postTextView: UITextView! {
		didSet {
			postTextView.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var heartButton: UIButton! {
		didSet {
			heartButton.theme_setTitleColor(KThemePicker.tableViewCellSubTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var commentButton: UIButton! {
		didSet {
			commentButton.theme_setTitleColor(KThemePicker.tableViewCellSubTextColor.rawValue, forState: .normal)
			commentButton.theme_tintColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var reshareButton: UIButton! {
		didSet {
			reshareButton.theme_setTitleColor(KThemePicker.tableViewCellSubTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var moreButton: UIButton! {
		didSet {
			moreButton.theme_tintColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
}
