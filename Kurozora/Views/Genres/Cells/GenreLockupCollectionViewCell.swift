//
//  GenreLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class GenreLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var symbolImageView: UIImageView!
	//	@IBOutlet weak var nsfwButton: UIButton!

	// MARK: - Properties
	var genre: Genre! {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configures the cell with th
	func configureCell() {
		self.contentView.backgroundColor = UIColor(hexString: self.genre.attributes.color)

		self.primaryLabel.text = self.genre.attributes.name
		self.secondaryLabel.text = self.genre.attributes.description
		self.symbolImageView.setImage(with: self.genre.attributes.symbol ?? "", placeholder: R.image.kurozoraIcon()!)
//		nsfwButton.isHidden = genre.attributes.isNSFW ? false : true
	}
}
