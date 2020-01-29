//
//  LibraryStatisticsCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class LibraryStatisticsCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var secondaryLabel: UILabel! {
		didSet {
			secondaryLabel.theme_textColor = KThemePicker.textColor.rawValue
			secondaryLabel.text = "\(69) TV · \(31) Movie · \(5) OVA/ONA/Specials"
		}
	}
}
