//
//  ExploreCategorySize.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/**
	List of available explore category size types.
*/
public enum ExploreCategorySize: String, Codable {
	// MARK: - Cases
	/**
		Indicates that the explore category has the `banner` size.

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
		Indicates that the explore category has the `large` size.

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
		Indicates that the explore category has the `medium` size.

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
		Indicates that the explore category has the `small` size.

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
		Indicates that the explore category has the `video` size.

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
