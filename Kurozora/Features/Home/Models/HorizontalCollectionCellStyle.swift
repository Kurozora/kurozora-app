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
	case banner = "BannerLockupCollectionViewCell"
	case large = "LargeLockupCollectionViewCell"
	case medium = "MediumLockupCollectionViewCell"
	case small = "SmallLockupCollectionViewCell"
	case video = "VideoLockupCollectionViewCell"
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
			return R.reuseIdentifier.bannerLockupCollectionViewCell.identifier
		case .large:
			return R.reuseIdentifier.largeLockupCollectionViewCell.identifier
		case .medium:
			return R.reuseIdentifier.mediumLockupCollectionViewCell.identifier
		case .small:
			return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
		case .video:
			return R.reuseIdentifier.videoLockupCollectionViewCell.identifier
		}
	}

	/// The class associated with the specified horizontal collection cell style.
	var classValue: BaseLockupCollectionViewCell.Type {
		switch self {
		case .banner:
			return BannerLockupCollectionViewCell.self
		case .large:
			return LargeLockupCollectionViewCell.self
		case .medium:
			return MediumLockupCollectionViewCell.self
		case .small:
			return SmallLockupCollectionViewCell.self
		case .video:
			return VideoLockupCollectionViewCell.self
		}
	}
}
