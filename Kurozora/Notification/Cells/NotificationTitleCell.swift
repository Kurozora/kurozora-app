//
//  NotificationTitleCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class NotificationTitleCell: UITableViewCell {
	@IBOutlet weak var notificationTitleLabel: UILabel! {
		didSet {
			notificationTitleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
}
