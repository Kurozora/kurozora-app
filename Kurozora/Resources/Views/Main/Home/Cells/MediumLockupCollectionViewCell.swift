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
	@IBOutlet weak var rankLabel: KLabel!
	@IBOutlet weak var backgroundColorView: GradientView!
	@IBOutlet weak var symbolImageView: UIImageView!

	// MARK: - Functions
	/// Configures the cell with the given `Genre` obejct.
	///
	/// - Parameters:
	///    - genre: The `Genre` object used to configure the cell.
	///    - rank: The rank of the genre in a ranked list.
	func configure(using genre: Genre?, rank: Int? = nil) {
		guard let genre = genre else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = genre.attributes.name

		self.configureRank(rank)

		self.backgroundColorView.backgroundColors = [
			UIColor(hexString: genre.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: genre.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]

		self.symbolImageView.setImage(with: genre.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}

	/// Configures the cell with the given `Theme` obejct.
	///
	/// - Parameters:
	///    - theme: The `Theme` object used to configure the cell.
	///    - rank: The rank of the theme in a ranked list.
	func configure(using theme: Theme?, rank: Int? = nil) {
		guard let theme = theme else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = theme.attributes.name

		self.configureRank(rank)

		self.backgroundColorView.backgroundColors = [
			UIColor(hexString: theme.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: theme.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]

		self.symbolImageView.setImage(with: theme.attributes.symbol?.url ?? "", placeholder: R.image.kurozoraIcon()!)
	}

	func configureRank(_ rank: Int?) {
		if let rank = rank {
			self.rankLabel.text = "# \(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}
	}
}
