//
//  ShowMoreCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

class ShowMoreCell: UITableViewCell {
    public class func registerNibFor(tableView: UITableView) {
        
        let listNib = UINib(nibName: "ShowMoreCell", bundle: KCommonKit.bundle())
        tableView.register(listNib, forCellReuseIdentifier: "ShowMoreCell")
    }
}
