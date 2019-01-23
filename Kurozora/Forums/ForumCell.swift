//
//  ForumCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ForumCellDelegate: class {
	func moreButtonPressed(cell: ForumCell)
	func upVoteButtonPressed(cell: ForumCell)
	func downVoteButtonPressed(cell: ForumCell)
}

public class ForumCell: UITableViewCell {
	weak var forumCellDelegate: ForumCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var contentLabel: UILabel!
	@IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var lockLabel: UILabel!

	// Actions
	@IBOutlet weak var moreButton: UIButton!
	@IBOutlet weak var upVoteButton: UIButton!
	@IBOutlet weak var downVoteButton: UIButton!

	@IBAction func moreButtonAction(_ sender: UIButton) {
		forumCellDelegate?.moreButtonPressed(cell: self)
	}

	@IBAction func upVoteButtonAction(_ sender: UIButton) {
		forumCellDelegate?.upVoteButtonPressed(cell: self)
		upVoteButton.animateBounce()
	}

	@IBAction func downVoteButtonAction(_ sender: UIButton) {
		forumCellDelegate?.downVoteButtonPressed(cell: self)
		downVoteButton.animateBounce()
	}
}
