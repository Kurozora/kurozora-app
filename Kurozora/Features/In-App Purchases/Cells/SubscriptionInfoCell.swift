//
//  SubscriptionInfoCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SubscriptionInfoCell: UITableViewCell {
	@IBOutlet weak var alreadyPurchasedButton: UIButton! {
		didSet {
			alreadyPurchasedButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var subscriptionInfoLabel: UILabel! {
		didSet {
			subscriptionInfoLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var moreInfoLabel: UILabel! {
		didSet {
			moreInfoLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var privacyButton: UIButton! {
		didSet {
			privacyButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
}
