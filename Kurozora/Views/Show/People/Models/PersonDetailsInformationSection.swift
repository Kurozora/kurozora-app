//
//  PersonDetailsInformationSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/**
	Set of available person details information sections.
*/
enum PersonDetailsInformationSection: Int, CaseIterable {
	// MARK: - Cases
	case givenName = 0
	case familyName
	case nicknames

	// MARK: - Properties
	/// The string value of a person details information section.
	var stringValue: String {
		switch self {
		case .givenName:
			return "Given Name"
		case .familyName:
			return "Family Name"
		case .nicknames:
			return "Nicknames"
		}
	}

	/// The cell identifier string of a person details information section.
	var identifierString: String {
		switch self {
		case .givenName:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .familyName:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .nicknames:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		}
	}

	// MARK: - Functions
	/**
		Returns the required information from the given object.

		- Parameter person: The object used to extract the infromation from.

		Returns: the required information from the given object.
	*/
	func information(from person: Person) -> String {
		switch self {
		case .givenName:
			return person.attributes.givenName ?? "-"
		case .familyName:
			return person.attributes.familyName ?? "-"
		case .nicknames:
			return person.attributes.nicknames?.joined(separator: ", ") ?? "-"
		}
	}
}
