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

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.contentView.layerCornerRadius = 22.0
		self.contentView.layer.cornerCurve = .continuous
		self.contentView.layer.borderWidth = self.contentView.hairlineWidth
		self.contentView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using productFeature: ProductFeature) {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		self.primaryLabel.text = productFeature.title
		self.secondaryLabel.text = productFeature.description
		self.productImageView.image = productFeature.image
	}
}
