//
//  MediumLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class MediumLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	override var primaryLabel: UILabel? {
		didSet {
			primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var backgroundColorView: UIView?

	// MARK: - Functions
	override func configureCell() {
		guard let genre = genre else { return }

		primaryLabel?.text = genre.attributes.name
		backgroundColorView?.backgroundColor = UIColor(hexString: genre.attributes.color)
		bannerImageView?.image = genre.attributes.symbolImage
	}
}
