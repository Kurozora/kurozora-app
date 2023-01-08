//
//  PurchaseButtonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

class PurchaseHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using primaryText: String?, secondaryText: String?) {
		self.primaryLabel.text = primaryText
		self.secondaryLabel.text = secondaryText
	}
}
