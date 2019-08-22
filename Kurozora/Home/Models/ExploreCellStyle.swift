//
//  ExploreCellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of Explore cell styles.

	```
	case large = "LargeExploreCollectionViewCell"
	case medium = "MediumExploreCollectionViewCell"
	case small = "SmallExploreCollectionViewCell"
	case video = "VideoExploreCollectionViewCell"
	```
*/
enum ExploreCellStyle: String {
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
