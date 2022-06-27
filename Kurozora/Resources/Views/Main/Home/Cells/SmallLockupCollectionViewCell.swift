//
//  SmallLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SmallLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!

	// MARK: - Functions
	override func configure(using show: Show?) {
		super.configure(using: show)

		// Configure tagline
		self.ternaryLabel?.text = nil

		let ratingAverage = show?.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0
	}

	/// Configures the cell using a `RelatedShow` object.
	///
	/// - Parameter relatedShow: The `RelatedShow` object used to configure the cell.
	func configure(using relatedShow: RelatedShow) {
		self.configure(using: relatedShow.show)

		self.ternaryLabel?.text = relatedShow.attributes.relation.name
		self.scoreView.isHidden = true
		self.scoreLabel.isHidden = true
	}
}
