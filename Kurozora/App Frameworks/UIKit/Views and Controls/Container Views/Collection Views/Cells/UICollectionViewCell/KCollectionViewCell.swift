//
//  KCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KCollectionViewCell: UICollectionViewCell, SkeletonDisplayable {
	// MARK: - Properties
	var isSkeletonEnabled: Bool {
		return true
	}

	/// Whether the cell exists only to be measured, and is never shown. Media set on such a cell resolves to its placeholder instead of being loaded.
	var isSizingCell = false

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		if self.isSkeletonEnabled {
			self.showSkeleton()
		}
	}
}
