//
//  CommentCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import TTTAttributedLabel_moolban

public class CommentCell: PostCell {
    
    public enum CommentType {
        case Text
        case Image
        case Video
    }
    
    public override class func registerNibFor(tableView: UITableView) {
        
        super.registerNibFor(tableView: tableView)
        
        do {
            let listNib = UINib(nibName: "CommentTextCell", bundle: KCommonKit.bundle())
            tableView.register(listNib, forCellReuseIdentifier: "CommentTextCell")
        }
        
        do {
            let listNib = UINib(nibName: "CommentImageCell", bundle: KCommonKit.bundle())
            tableView.register(listNib, forCellReuseIdentifier: "CommentImageCell")
        }
    }
    
}
