//
//  ForumCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
// 83L1mS4C

import UIKit
import SwiftyJSON

public class ForumCell: UITableViewCell {
	var forumsChildViewController: ForumsChildViewController?
	var thread: JSON?

    @IBOutlet public weak var titleLabel: UILabel!
	@IBOutlet weak var contentLabel: UILabel!
	@IBOutlet public weak var informationLabel: UILabel!
    @IBOutlet public weak var typeLabel: UILabel!

	// Actions
	@IBOutlet weak var moreButton: UIButton!
	@IBOutlet weak var upVoteButton: UIButton!
	@IBOutlet weak var downVoteButton: UIButton!

	@IBAction func moreButtonAction(_ sender: Any) {
	}

	@IBAction func upVoteButtonAction(_ sender: Any) {
	}

	@IBAction func downVoteButtonAction(_ sender: UIButton) {
	}

}
