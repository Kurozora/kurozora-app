//
//  MediumLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class MediumLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	override var primaryLabel: UILabel? {
		didSet {
			primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var backgroundColorView: UIView?

	// MARK: - Functions
	override func configureCell(with genre: Genre) {
		primaryLabel?.text = genre.attributes.name
		backgroundColorView?.backgroundColor = UIColor(hexString: genre.attributes.color)
		bannerImageView?.setImage(with: genre.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}

	override func configureCell(with theme: Theme) {
		primaryLabel?.text = theme.attributes.name
		backgroundColorView?.backgroundColor = UIColor(hexString: theme.attributes.color)
		bannerImageView?.setImage(with: theme.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}
}
