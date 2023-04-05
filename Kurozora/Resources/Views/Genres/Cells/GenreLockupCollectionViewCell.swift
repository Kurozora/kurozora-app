//
//  GenreLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class GenreLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KUnderlinedLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var symbolImageView: UIImageView!
	@IBOutlet weak var patterImageView: UIImageView!
	@IBOutlet weak var borderView: UIView!
	@IBOutlet weak var gradientView: GradientView!

	// MARK: - Functions
	/// Configures the cell with the given `Genre` obejct.
	///
	/// - Parameter genre: The `Genre` object used to configure the cell.
	func configure(using genre: Genre?) {
		guard let genre = genre else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.gradientView.gradientLayer.colors = [
			UIColor(hexString: genre.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: genre.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]

		self.borderView.backgroundColor = UIColor(hexString: genre.attributes.backgroundColor2)

		self.primaryLabel.text = genre.attributes.name.uppercased()
		self.primaryLabel.textColor = UIColor(hexString: genre.attributes.textColor1)

		self.secondaryLabel.text = genre.attributes.description?.uppercased()
		self.secondaryLabel.textColor = UIColor(hexString: genre.attributes.textColor2)

		self.symbolImageView.setImage(with: genre.attributes.symbol?.url ?? "", placeholder: UIImage())

		self.contentView.cornerRadius = 10.0
	}
}
