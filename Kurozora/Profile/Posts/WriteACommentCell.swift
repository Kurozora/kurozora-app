//
//  WriteACommentCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class WriteACommentCell: UITableViewCell {
    public class func registerNibFor(tableView: UITableView) {
        let listNib = UINib(nibName: "WriteACommentCell", bundle: nil)
        tableView.register(listNib, forCellReuseIdentifier: "WriteACommentCell")
    }
}
