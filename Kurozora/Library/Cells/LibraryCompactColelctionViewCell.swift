//
//  LibraryCompactColelctionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryCompactColelctionViewCell: LibraryCollectionViewCell {
	@IBOutlet override var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
}
