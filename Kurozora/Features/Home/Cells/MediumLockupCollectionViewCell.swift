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
		guard let genreElement = genreElement else { return }
		guard let genreColor = genreElement.color else { return }

		primaryLabel?.text = genreElement.name
		backgroundColorView?.backgroundColor = UIColor(hexString: genreColor)

		if let symbol = genreElement.symbol {
			bannerImageView?.setImage(with: symbol, placeholder: R.image.kurozora_icon()!)
		}

		shadowView?.applyShadow()
	}
}
