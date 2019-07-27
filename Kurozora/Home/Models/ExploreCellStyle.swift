//
//  ExploreCellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of Explore cell styles

	- case large
	- case medium
	- case small
	- case video
*/
enum ExploreCellStyle: String {
	case large
	case medium
	case small
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
