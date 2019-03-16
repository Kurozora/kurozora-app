//
//  FootnoteCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class FootnoteCell: UITableViewCell {
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet weak var termsConditionsLabel: UILabel!
	@IBOutlet weak var chevronImageView: UIImageView!

	override func didMoveToSuperview() {
		super.didMoveToSuperview()

		separatorView.theme_backgroundColor = "Global.separatorColor"
		termsConditionsLabel.theme_textColor = "Global.textColor"
		termsConditionsLabel.alpha = 0.50
		chevronImageView.theme_tintColor = "Global.textColor"
		chevronImageView.alpha = 0.60
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		if highlighted {
			termsConditionsLabel.alpha = 0.30
			chevronImageView.alpha = 0.40
		} else {
			termsConditionsLabel.alpha = 0.50
			chevronImageView.alpha = 0.60
		}
	}
}
