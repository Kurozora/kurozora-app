//
//  LegalCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LegalCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var separatorView: SeparatorView!
	@IBOutlet weak var termsConditionsLabel: KSecondaryLabel!
	@IBOutlet weak var chevronButtonView: UIButton! {
		didSet {
			self.chevronButtonView.theme_tintColor = KThemePicker.subTextColor.rawValue
		}
	}
}
