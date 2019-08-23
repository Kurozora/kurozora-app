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
			postTextView?.text = """
			2019-08-06 19:09:45.764253+0200 Kurozora[24462:2644879] [UIWorkIntervalTiming] workIntervalStart: startTimestamp > targetTimestamp; rolling forward by 0.116667
			2019-08-06 19:09:49.973019+0200 Kurozora[24462:2644879] [WindowServer] display_timer_callback: unexpected state (now:bade0c031633 < expected:bade0cf5fc05)
			2019-08-06 19:09:50.156940+0200 Kurozora[24462:2644879] [WindowServer] display_timer_callback: unexpected state (now:bade16f97da4 < expected:bade17f24d0c)
			2019-08-06 19:09:50.676423+0200 Kurozora[24462:2644879] [WindowServer] display_timer_callback: unexpected state (now:bade35f010c4 < expected:bade36e30a3b)
			2019-08-06 19:09:51.595150+0200 Kurozora[24462:2644879] [WindowServer] display_timer_callback: unexpected state (now:bade6cb29afc < expected:bade6d8926c4)
			2019-08-06 19:09:52.078944+0200 Kurozora[24462:2644879] [UIWorkIntervalTiming] workIntervalStart: startTimestamp > targetTimestamp; rolling forward by 0.550000
			2019-08-06 19:09:53.407011+0200 Kurozora[24462:2644879] [WindowServer] display_timer_callback: unexpected state (now:baded8b12118 < expected:baded9a96ee6)
			"""
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
