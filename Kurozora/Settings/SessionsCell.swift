//
//  SessionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit
import Alamofire
import SwiftyJSON
import SCLAlertView

class SessionsCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: DesignableView!
    @IBOutlet weak var ipAddressLable: UILabel!
    @IBOutlet weak var ipAddressValueLable: UILabel!
    @IBOutlet weak var deviceTypeLable: UILabel!
    @IBOutlet weak var deviceTypeValueLable: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var dateValueLable: UILabel!
    @IBOutlet weak var removeSessionButton: DesignableButton!
    
    @IBOutlet weak var extraLable: UILabel!
    
}
