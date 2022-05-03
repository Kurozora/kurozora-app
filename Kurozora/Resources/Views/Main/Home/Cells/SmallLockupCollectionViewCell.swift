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
	// MARK: - Functions
	override func configure(using show: Show?) {
		super.configure(using: show)

		self.ternaryLabel?.text = nil
	}

	/// Configures the cell using a `RelatedShow` object.
	///
	/// - Parameter relatedShow: The `RelatedShow` object used to configure the cell.
	func configure(using relatedShow: RelatedShow) {
		self.configure(using: relatedShow.show)

		self.ternaryLabel?.text = relatedShow.attributes.relation.name
	}
}
