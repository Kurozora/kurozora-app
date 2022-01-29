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

	// MARK: - Functions
	func configureCell(with relatedShow: RelatedShow) {
		self.configureCell(with: relatedShow.show)

		self.ternaryLabel.text = relatedShow.attributes.relation.name
	}
}
