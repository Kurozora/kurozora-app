//
//  SubscriptionButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SubscriptionButtonTableViewCell: UITableViewCell {
	@IBOutlet weak var subscriptionButton: UIButton! {
		didSet {
			subscriptionButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			subscriptionButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var subtextLabel: UILabel! {
		didSet {
			subtextLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	var subscriptionItem: [String: String]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let subscriptionItem = subscriptionItem else { return }
		subscriptionButton.setTitle(subscriptionItem["title"], for: .normal)
		subtextLabel.text = subscriptionItem["subtext"]
	}
}
