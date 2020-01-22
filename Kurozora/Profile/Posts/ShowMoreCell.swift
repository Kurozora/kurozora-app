//
//  ShowMoreCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class ShowMoreCell: UITableViewCell {
    public class func registerNibFor(tableView: UITableView) {
        let listNib = UINib(nibName: "ShowMoreCell", bundle: nil)
        tableView.register(listNib, forCellReuseIdentifier: "ShowMoreCell")
    }
}
