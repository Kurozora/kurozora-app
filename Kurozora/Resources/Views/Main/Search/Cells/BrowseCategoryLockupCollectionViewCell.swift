//
//  BrowseCategoryLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/05/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BrowseCategoryLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel!
	@IBOutlet weak var primaryImageView: UIImageView!

	// MARK: - Functions
	/// Configures the cell with the given `BrowseCategory` obejct.
	///
	/// - Parameters:
	///    - browseCategory: The `BrowseCategory` object used to configure the cell.
	func configure(using browseCategory: BrowseCategory) {
		self.hideSkeleton()

		self.contentView.layerCornerRadius = 10.0

		self.primaryLabel.text = browseCategory.title
		self.primaryImageView.image = browseCategory.image
	}
}
