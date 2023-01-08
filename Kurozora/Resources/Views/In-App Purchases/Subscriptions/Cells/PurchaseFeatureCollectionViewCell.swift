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
	@IBOutlet weak var productImageView: KImageView!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using subscriptionFeature: SubscriptionFeature) {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		self.primaryLabel.text = subscriptionFeature.title
		self.secondaryLabel.text = subscriptionFeature.description
		self.productImageView.image = subscriptionFeature.image
	}
}
