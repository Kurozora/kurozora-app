//
//  RecapLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/01/2024.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RecapLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	/// The primary lable of the cell.
	@IBOutlet weak var primaryLabel: UILabel!

	/// The lofo image of the cell.
	@IBOutlet weak var logoImageView: UIImageView!

	/// The album image of the cell.
	@IBOutlet weak var albumImageView: RoundedRectangleImageView!

	/// The gradient on top of `albumImageView`.
	@IBOutlet weak var gradientView: GradientView!

	// MARK: - Functions
	/// Configures the cell with the given `ShowSong` object.
	///
	/// - Parameter recap: The `Recap` object used to configure the cell.
	func configure(using recap: Recap?) {
		guard let recap = recap else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.logoImageView.tintColor = .white

		self.gradientView.backgroundColors = [
			UIColor(hexString: recap.attributes.backgroundColor1)?.cgColor ?? UIColor.orange.cgColor,
			UIColor(hexString: recap.attributes.backgroundColor2)?.cgColor ?? UIColor.purple.cgColor
		]
		self.gradientView.alpha = 0.5

		self.primaryLabel.text = "’\(recap.attributes.year % 100)"
		self.primaryLabel.textColor = .white.withAlphaComponent(0.92)
	}
}
