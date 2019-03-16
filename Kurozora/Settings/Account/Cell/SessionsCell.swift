//
//  SessionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView

class SessionsCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var ipAddressValueLabel: UILabel!
    @IBOutlet weak var deviceTypeValueLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var removeSessionButton: UIButton!
    
    @IBOutlet weak var extraLabel: UILabel!
}
