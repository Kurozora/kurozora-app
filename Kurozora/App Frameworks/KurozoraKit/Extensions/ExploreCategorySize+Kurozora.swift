//
//  ExploreCategorySize.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit

extension ExploreCategorySize {
	// MARK: - Properties
	/// The cell identifier string of an explore category size type.
	var identifierString: String {
		switch self {
		case .banner:
			return R.reuseIdentifier.bannerLockupCollectionViewCell.identifier
		case .large:
			return R.reuseIdentifier.largeLockupCollectionViewCell.identifier
		case .medium:
			return R.reuseIdentifier.mediumLockupCollectionViewCell.identifier
		case .small:
			return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
		case .upcoming:
			return R.reuseIdentifier.upcomingLockupCollectionViewCell.identifier
		case .video:
			return R.reuseIdentifier.videoLockupCollectionViewCell.identifier
		}
	}
}
