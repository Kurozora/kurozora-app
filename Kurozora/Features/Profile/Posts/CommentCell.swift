//
//  CommentCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class CommentCell: PostCell {
    public enum CommentType {
        case text
        case image
        case video
    }

	// NOTE: - LOOK AT THIS
	override class func registerNibFor(tableView: UITableView) {
        super.registerNibFor(tableView: tableView)

        do {
            let listNib = UINib(nibName: "CommentTextCell", bundle: nil)
            tableView.register(listNib, forCellReuseIdentifier: "CommentTextCell")
        }

        do {
			tableView.register(R.nib.commentImageCell)
        }
    }
}
