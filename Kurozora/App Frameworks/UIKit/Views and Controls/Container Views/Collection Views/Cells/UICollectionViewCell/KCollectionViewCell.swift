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

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		if self.isSkeletonEnabled {
			self.showSkeleton()
		}
	}
}
