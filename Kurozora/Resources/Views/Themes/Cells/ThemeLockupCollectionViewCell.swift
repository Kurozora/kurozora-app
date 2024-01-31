//
//  ThemeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ThemeLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KUnderlinedLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var symbolImageView: UIImageView!
	@IBOutlet weak var patterImageView: UIImageView!
	@IBOutlet weak var borderView: UIView!
	@IBOutlet weak var gradientView: GradientView!

	// MARK: - Functions
	/// Configures the cell with the given `Theme` obejct.
	///
	/// - Parameter theme: The `Theme` object used to configure the cell.
	func configure(using theme: Theme?) {
		guard let theme = theme else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.gradientView.backgroundColors = [
			UIColor(hexString: theme.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: theme.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]

		self.borderView.backgroundColor = UIColor(hexString: theme.attributes.backgroundColor2)

		self.primaryLabel.text = theme.attributes.name.uppercased()
		self.primaryLabel.textColor = UIColor(hexString: theme.attributes.textColor1)

		self.secondaryLabel.text = theme.attributes.description?.uppercased()
		self.secondaryLabel.textColor = UIColor(hexString: theme.attributes.textColor2)

		self.symbolImageView.setImage(with: theme.attributes.symbol?.url ?? "", placeholder: UIImage())

		self.contentView.layerCornerRadius = 10.0
	}
}
