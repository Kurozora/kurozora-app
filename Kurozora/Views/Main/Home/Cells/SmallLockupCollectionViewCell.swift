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
	@IBOutlet weak var ternaryLabel: KSecondaryLabel!

	// MARK: - Properties
	var relatedShow: RelatedShow? {
		didSet {
			self.show = self.relatedShow?.show
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		self.ternaryLabel.text = self.relatedShow?.attributes.relation.name
	}
}
