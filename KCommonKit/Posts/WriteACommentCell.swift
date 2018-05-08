//
//  WriteACommentCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

class WriteACommentCell: UITableViewCell {
    public class func registerNibFor(tableView: UITableView) {
        
        let listNib = UINib(nibName: "WriteACommentCell", bundle: KCommonKit.bundle())
        tableView.register(listNib, forCellReuseIdentifier: "WriteACommentCell")
    }
}
