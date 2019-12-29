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
	/**
		Indicates that the cell has the `banner` style.

		```
		//   +-----------------------------------------------------+
		//   | +----------------------------------------+  +-------|
		//   |                                                     |
		//   | +----------------------------------------+  +-------|
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                    0                   |  |   1   |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | +----------------------------------------+  +-------|
		//   +-----------------------------------------------------+
		```
	*/
	case banner

	/**
		Indicates that the cell has the `large` style.

		```
		//   +-----------------------------------------------------+
		//   | +----------------------------------------+  +-------|
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                    0                   |  |   1   |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | +----------------------------------------+  +-------|
		//   +-----------------------------------------------------+
		```
	*/
	case large

	/**
		Indicates that the cell has the `medium` style.

		```
		//   +-----------------------------------------------------+
		//   | +----------------------------+  +-------------------|
		//   | |                            |  |                   |
		//   | |                            |  |                   |
		//   | |                            |  |                   |
		//   | |                            |  |                   |
		//   | |              0             |  |              1    |
		//   | |                            |  |                   |
		//   | |                            |  |                   |
		//   | |                            |  |                   |
		//   | +----------------------------+  +-------------------|
		//   +-----------------------------------------------------+
		```
	*/
	case medium

	/**
		Indicates that the cell has the `small` style.

		```
		//   +-----------------------------------------------------+
		//   | +-------------+  +-------------+  +-------------+  +|
		//   | |             |  |             |  |             |  ||
		//   | |             |  |             |  |             |  ||
		//   | |             |  |             |  |             |  ||
		//   | |      0      |  |      1      |  |      2      |  ||
		//   | |             |  |             |  |             |  ||
		//   | |             |  |             |  |             |  ||
		//   | |             |  |             |  |             |  ||
		//   | |             |  |             |  |             |  ||
		//   | +-------------+  +-------------+  +-------------+  +|
		//   +-----------------------------------------------------+
		```
	*/
	case small

	/**
		Indicates that the cell has the `video` style.

		```
		//   +-----------------------------------------------------+
		//   | +----------------------------------------+  +-------|
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                    0                   |  |   1   |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | |                                        |  |       |
		//   | +----------------------------------------+  +-------|
		//   | +-------------+                             +-------|
		//   | |             |                             |       |
		//   | |             |                             |       |
		//   | |             |                             |       |
		//   | |      0      |                             |   1   |
		//   | |             |                             |       |
		//   | |             |                             |       |
		//   | |             |                             |       |
		//   | |             |                             |       |
		//   | +-------------+                             +-------|
		//   +-----------------------------------------------------+
		```
	*/
	case video
}

// MARK: - Properties
extension HorizontalCollectionCellStyle {
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
}
