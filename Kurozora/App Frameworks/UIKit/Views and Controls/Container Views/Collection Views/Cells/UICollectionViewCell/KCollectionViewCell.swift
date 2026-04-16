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
	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.showSkeleton()
	}
}
