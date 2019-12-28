//
//  LegalExploreTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LegalExploreCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var termsConditionsLabel: UILabel! {
		didSet {
			termsConditionsLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var chevronButtonView: UIButton! {
		didSet {
			chevronButtonView.theme_tintColor = KThemePicker.subTextColor.rawValue
		}
	}
}
