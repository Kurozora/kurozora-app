//
//  HorizontalCollectionCellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

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

	/// The cell identifier string of a horizontal collection cell style.
	var identifierString: String {
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

	/// The size value of a horizontal collection cell style.
	var sizeValue: CGSize {
		switch self {
		case .banner:
			return CGSize(width: 375, height: 235)
		case .medium:
			return CGSize(width: 375, height: 211)
		case .small:
			return CGSize(width: 375, height: 211)
		case .video:
			return CGSize(width: 375, height: 390)
		default:
			return .zero
		}
	}
}
