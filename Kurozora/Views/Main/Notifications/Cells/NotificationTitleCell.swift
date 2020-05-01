//
//  NotificationTitleCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class NotificationTitleCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var notificationTitleLabel: KLabel!
	@IBOutlet weak var notificationMarkButton: UIButton! {
		didSet {
			notificationMarkButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
}
