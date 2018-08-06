//
//  NotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class NotificationCell : UITableViewCell {
    
    @IBOutlet weak var notificationBody: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var notificationTextLable: UILabel!
    
    @IBOutlet weak var notificationHeader: UIView!
    @IBOutlet weak var notificationDate: UILabel!
    @IBOutlet weak var notificationType: UILabel!
    @IBOutlet weak var notificationIcon: UIImageView!
    
}
