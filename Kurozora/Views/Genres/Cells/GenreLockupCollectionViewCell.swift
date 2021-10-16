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

	// MARK: - Properties
	var genre: Genre! {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configures the cell with th
	func configureCell() {
		switch self.genre.attributes.color.lowercased() {
		case "#ffffff":
			self.contentView.backgroundColor = #colorLiteral(red: 0.2174204886, green: 0.2404745221, blue: 0.3324468732, alpha: 1)
		default:
			self.contentView.backgroundColor = UIColor(hexString: self.genre.attributes.color)
		}

		self.primaryLabel.text = self.genre.attributes.name
		self.secondaryLabel.text = self.genre.attributes.description
		self.symbolImageView.setImage(with: self.genre.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}
}
