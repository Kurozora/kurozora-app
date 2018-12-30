//
//  NotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class MessageNotificationCell: UITableViewCell {
    // Header
    @IBOutlet weak var notificationDate: UILabel!
    @IBOutlet weak var notificationType: UILabel!
    @IBOutlet weak var notificationIcon: UIImageView!
    
    // Body
    @IBOutlet weak var notificationProfileImage: UIImageView!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationTextLable: UILabel!
}

class SessionNotificationCell: UITableViewCell {
    // Header
    @IBOutlet weak var notificationDate: UILabel!
    @IBOutlet weak var notificationType: UILabel!
    @IBOutlet weak var notificationIcon: UIImageView!
    
    // Body
    @IBOutlet weak var notificationTextLable: UILabel!
}

class TitleNotificationCell: UITableViewCell {
	@IBOutlet weak var notificationTitleLable: UILabel!
}
