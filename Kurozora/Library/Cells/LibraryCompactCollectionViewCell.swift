//
//  LibraryCompactCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryCompactCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - IBOutlets
	override var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		posterShadowView?.applyShadow()
	}
}
