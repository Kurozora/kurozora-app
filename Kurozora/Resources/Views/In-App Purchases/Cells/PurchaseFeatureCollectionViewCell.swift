//
//  PurchaseFeatureCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

class PurchaseFeatureCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var productImageView: AspectRatioImageView!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using productFeature: ProductFeature) {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		self.primaryLabel.text = productFeature.title
		self.secondaryLabel.text = productFeature.description
		self.productImageView.image = productFeature.image
	}
}
