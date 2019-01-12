//
//  CommentCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class CommentCell: PostCell {
    public enum CommentType {
        case text
        case image
        case video
    }

	override class func registerNibFor(tableView: UITableView) {
        super.registerNibFor(tableView: tableView)

        do {
            let listNib = UINib(nibName: "CommentTextCell", bundle: nil)
            tableView.register(listNib, forCellReuseIdentifier: "CommentTextCell")
        }

        do {
            let listNib = UINib(nibName: "CommentImageCell", bundle: nil)
            tableView.register(listNib, forCellReuseIdentifier: "CommentImageCell")
        }
    }
}
