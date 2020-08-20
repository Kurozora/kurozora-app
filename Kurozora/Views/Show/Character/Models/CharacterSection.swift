//
//  CharacterSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	List of charcter section layout kind.

	```
	case main = 0
	case about = 1
	case information = 2
	case shows = 3
	case actors = 4
	```
*/
enum CharacterSection: Int, CaseIterable {
	// MARK: - Cases
	case main = 0
	case about = 1
	case information = 2
	case shows = 3
	case actors = 4

	// MARK: - Properties
	/// The string value of a character section layout kind.
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
		case .actors:
			return "Actors"
		}
	}

	/// The row count of a character section layout kind.
	var rowCount: Int {
		switch self {
		case .main:
			return 1
		case .about:
			return 1
		case .information:
			return CharacterInformationSection.allCases.count
		case .shows:
			return 0
		case .actors:
			return 0
		}
	}

	// MARK: - Functions
	/**
		The cell identifier string of a character section.

		- Parameter row: The row integer used to determine the cell reuse identifier.

		- Returns: The cell identifier string of a character section.
	*/
	func identifierString(for row: Int = 0) -> String {
		switch self {
		case .main:
			return R.reuseIdentifier.characterHeaderCollectionViewCell.identifier
		case .about:
			return R.reuseIdentifier.textViewCollectionViewCell.identifier
		case .information:
			return CharacterInformationSection(rawValue: row)?.identifierString ?? CharacterInformationSection.debut.identifierString
		case .shows:
			return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
		case .actors:
			return R.reuseIdentifier.actorLockupCollectionViewCell.identifier
		}
	}

	/// The string value of a character section type segue identifier.
	var segueIdentifier: String {
		switch self {
		case .main:
			return ""
		case .about:
			return ""
		case .information:
			return ""
		case .shows:
			return R.segue.characterDetailsCollectionViewController.showsListSegue.identifier
		case .actors:
			return R.segue.characterDetailsCollectionViewController.actorsListSegue.identifier
		}
	}
}
