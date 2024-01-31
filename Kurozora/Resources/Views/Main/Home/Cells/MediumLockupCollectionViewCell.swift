//
//  MediumLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class MediumLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var backgroundColorView: GradientView!
	@IBOutlet weak var symbolImageView: UIImageView!

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

		self.primaryLabel.text = genre.attributes.name

		self.backgroundColorView.backgroundColors = [
			UIColor(hexString: genre.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: genre.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]

		self.symbolImageView.setImage(with: genre.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}

	/// Configures the cell with the given `Theme` obejct.
	///
	/// - Parameter theme: The `Theme` object used to configure the cell.
	func configure(using theme: Theme?) {
		guard let theme = theme else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = theme.attributes.name

		self.backgroundColorView.backgroundColors = [
			UIColor(hexString: theme.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: theme.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]

		self.symbolImageView.setImage(with: theme.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}
}
