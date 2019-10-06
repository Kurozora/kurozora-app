//
//  PurchaseHeaderTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class PurchaseHeaderTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var secondaryLabel: UILabel? {
		didSet {
			secondaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
}
