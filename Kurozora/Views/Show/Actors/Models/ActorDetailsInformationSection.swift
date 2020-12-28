//
//  ActorDetailsInformationSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/**
	Set of available actor details information sections.
*/
enum ActorDetailsInformationSection: Int, CaseIterable {
	// MARK: - Cases
	case occupation = 0

	// MARK: - Properties
	/// The string value of a actor details information section.
	var stringValue: String {
		switch self {
		case .occupation:
			return "Occupation"
		}
	}

	/// The cell identifier string of a actor details information section.
	var identifierString: String {
		switch self {
		case .occupation:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		}
	}

	// MARK: - Functions
	/**
		Returns the required information from the given object.

		- Parameter actor: The object used to extract the infromation from.

		Returns: the required information from the given object.
	*/
	func information(from actor: Actor) -> String {
		switch self {
		case .occupation:
			if let occupation = actor.attributes.occupation {
				return occupation
			}
		}
		return "-"
	}
}
