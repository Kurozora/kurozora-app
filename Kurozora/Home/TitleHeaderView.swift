//
//  TitleHeaderView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import UIKit

class TitleHeaderView: UITableViewCell {

    static let id = "TitleHeaderView"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionContentView: UIView!
    
    var actionButtonCallback: ((Int) -> Void)?
    var section: Int = 0
    
    class func registerNibFor(tableView: UITableView) {
        let chartNib = UINib(nibName: TitleHeaderView.id, bundle: nil)
        tableView.register(chartNib, forCellReuseIdentifier: TitleHeaderView.id)
    }
    
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        actionButtonCallback?(section)
    }

    
}
