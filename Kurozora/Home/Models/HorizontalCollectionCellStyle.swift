//
//  HorizontalCollectionCellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of horizontal explore cell styles.

	```
	case banner = "BannerExploreCollectionViewCell"
	case large = "LargeExploreCollectionViewCell"
	case medium = "MediumExploreCollectionViewCell"
	case small = "SmallExploreCollectionViewCell"
	case video = "VideoExploreCollectionViewCell"
	```
*/
enum HorizontalCollectionCellStyle: String {
	/// Indicates that the cell has the `banner` style.
	case banner

	/// Indicates that the cell has the `large` style.
	case large

	/// Indicates that the cell has the `medium` style.
	case medium

	/// Indicates that the cell has the `small` style.
	case small

	/// Indicates that the cell has the `video` style.
	case video

	var reuseIdentifier: String {
		switch self {
		case .banner:
			return "BannerExploreCollectionViewCell"
		case .large:
			return "LargeExploreCollectionViewCell"
		case .medium:
			return "MediumExploreCollectionViewCell"
		case .small:
			return "SmallExploreCollectionViewCell"
		case .video:
			return "VideoExploreCollectionViewCell"
		}
	}
}
