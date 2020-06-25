//
//  StudioInformationSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	List of studio section layout kind.

	```
	case main = 0
	case about = 1
	case information = 2
	case shows = 3
	```
*/
enum StudioSection: Int, CaseIterable {
	// MARK: - Cases
	case main = 0
	case about = 1
	case information = 2
	case shows = 3

	// MARK: - Properties
	/// The string value of a studio section layout kind.
	var stringValue: String {
		switch self {
		case .main:
			return ""
		case .about:
			return "About"
		case .information:
			return "Information"
		case .shows:
			return "Shows"
		}
	}

	/// The row count of a studio section layout kind.
	var rowCount: Int {
		switch self {
		case .main:
			return 1
		case .about:
			return 1
		case .information:
			return StudioInformationSection.allCases.count
		case .shows:
			return 0
		}
	}

	// MARK: - Functions
	/**
		The cell identifier string of a studio section.

		- Parameter row: The row integer used to determine the cell reuse identifier.

		- Returns: The cell identifier string of a studio section.
	*/
	func identifierString(for row: Int = 0) -> String {
		switch self {
		case .main:
			return R.reuseIdentifier.studioHeaderCollectionViewCell.identifier
		case .about:
			return R.reuseIdentifier.textViewCollectionViewCell.identifier
		case .information:
			return StudioInformationSection(rawValue: row)?.identifierString ?? StudioInformationSection.website.identifierString
		case .shows:
			return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
		}
	}
}
