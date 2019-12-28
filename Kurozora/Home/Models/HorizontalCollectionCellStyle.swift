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

	/// The item content insets of a horizontal collection cell style.
	var itemContentInsets: NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
	}

	/// The section content insets of a horizontal collection cell style.
	var sectionContentInsets: NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
	}
}

// MARK: - Functions
extension HorizontalCollectionCellStyle {
	/**
		Reutrns the number of columns the collection view should present.

		Number of columns is calculated by deviding the max width of the cell with the total width of the collection view.

		- Parameter width: The width of the collection view used to calculate the number of columns.

		- Returns: the number of columns the collection view should present.
	*/
	func columnCount(for width: CGFloat) -> Int {
		var columnCount = 0

		switch self {
		case .banner:
			if width > 414 {
				columnCount = (width / 562).int
			} else {
				columnCount = (width / 374).int
			}
		case .large:
			if width > 414 {
				columnCount = (width / 500).int
			} else {
				columnCount = (width / 324).int
			}
		case .medium:
			if width > 414 {
				columnCount = (width / 384).int
			} else {
				columnCount = (width / 284).int
			}
		case .small:
			if width > 414 {
				columnCount = (width / 384).int
			} else {
				columnCount = (width / 284).int
			}
		case .video:
			if width > 414 {
				columnCount = (width / 500).int
			} else {
				columnCount = (width / 360).int
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	/**
		Returns the CGFloat value of the collection view group height fraction.

		When the width of the cell is longer than the height, the fractional height is calculated by deviding the fractional height for one column with the number of columns the collection view is currenlty presenting.

		- Parameter column: The number of columns used to determin the fractional height value.

		- Returns: the CGFloat value of the collection view group height fraction.
	*/
	func groupHeightFraction(for column: Int) -> CGFloat {
		switch self {
		case .banner:
			return (0.55 / column.double).cgFloat
		case .large:
			return (0.55 / column.double).cgFloat
		case .medium:
			return (0.60 / column.double).cgFloat
		case .small:
			return (0.55 / column.double).cgFloat
		case .video:
			if column <= 1 {
				return (0.75 / column.double).cgFloat
			}
			return (0.92 / column.double).cgFloat
		}
	}
}
