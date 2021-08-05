//
//  PersonDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum PersonDetail {
	/**
		List of person section type.

		```
		case header = 0
		case about
		case information
		case shows
		```
	*/
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		case header = 0
		case about
		case information
		case shows
		case characters

		// MARK: - Properties
		/// The string value of a character section type.
		var stringValue: String {
			switch self {
			case .header:
				return "Header"
			case .about:
				return "About"
			case .information:
				return "Information"
			case .shows:
				return "Shows"
			case .characters:
				return "Characters"
			}
		}

		/// The row count of a character section type.
		var rowCount: Int {
			switch self {
			case .header:
				return 1
			case .about:
				return 1
			case .information:
				return PersonDetail.Information.allCases.count
			case .shows:
				return 0
			case .characters:
				return 0
			}
		}

		/// The string value of a character section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .about:
				return ""
			case .information:
				return ""
			case .shows:
				return R.segue.personDetailsCollectionViewController.showsListSegue.identifier
			case .characters:
				return R.segue.personDetailsCollectionViewController.charactersListSegue.identifier
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
			case .header:
				return R.reuseIdentifier.personHeaderCollectionViewCell.identifier
			case .about:
				return R.reuseIdentifier.textViewCollectionViewCell.identifier
			case .information:
				return PersonDetail.Information(rawValue: row)?.identifierString ?? PersonDetail.Information.aliases.identifierString
			case .shows:
				return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
			case .characters:
				return R.reuseIdentifier.characterLockupCollectionViewCell.identifier
			}
		}
	}
}

// MARK: Information
extension PersonDetail {
	/**
		Set of available person infromation types.
	*/
	enum Information: Int, CaseIterable {
		// MARK: - Cases
		case aliases = 0
		case age
		case characteristics

		// MARK: - Properties
		/// The string value of a person infromation type.
		var stringValue: String {
			switch self {
			case .aliases:
				return "Aliases"
			case .age:
				return "Age"
			case .characteristics:
				return "Characteristics"
			}
		}

		/// The image value of a person information type.
		var imageValue: UIImage? {
			switch self {
			case .aliases:
				return UIImage(systemName: "person")
			case .age:
				return UIImage(systemName: "calendar")
			case .characteristics:
				return UIImage(systemName: "list.bullet.rectangle")
			}
		}

		/// The cell identifier string of a person infromation type.
		var identifierString: String {
			switch self {
			case .aliases:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .age:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .characteristics:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/**
			Returns the required information from the given object.

			- Parameter person: The object used to extract the infromation from.

			Returns: the required information from the given object.
		*/
		func information(from person: Person) -> String? {
			switch self {
			case .aliases:
				var aliases = "Name: \(person.attributes.fullName)"
				if let givenName = person.attributes.fullGivenName {
					aliases += "\nGiven Name: \(givenName)"
				}

				if let alternativeNames = person.attributes.alternativeNames, !alternativeNames.isEmpty {
					aliases += "\nNicknames: \(alternativeNames.joined(separator: ", "))"
				}
				return aliases
			case .age:
				if let age = person.attributes.age, !age.isEmpty {
					return age
				}
			case .characteristics:
				return nil
			}
			return nil
		}

		/**
			Returns the required primary information from the given object.

			- Parameter person: The object used to extract the infromation from.

			- Returns: the required primary information from the given object.
		*/
		func primaryInformation(from person: Person) -> String? {
			switch self {
			default: return nil
			}
		}

		/**
			Returns the required secondary information from the given object.

			- Parameter person: The object used to extract the infromation from.

			- Returns: the required secondary information from the given object.
		*/
		func secondaryInformation(from person: Person) -> String? {
			switch self {
			default: return nil
			}
		}

		/**
			Returns the required primary image from the given object.

			- Parameter person: The object used to extract the infromation from.

			- Returns: the required primary image from the given object.
		*/
		func primaryImage(from person: Person) -> UIImage? {
			switch self {
			default: return nil
			}
		}

		/**
			Returns the footnote from the given object.

			- Parameter person: The object used to extract the footnote from.

			- Returns: the footnote from the given object.
		*/
		func footnote(from person: Person) -> String? {
			switch self {
			case .age:
				var ageFootnote = ""
				if let birthdate = person.attributes.birthdate {
					ageFootnote += birthdate.formatted(date: .long, time: .omitted)
				}

				if let astrologicalSign = person.attributes.astrologicalSign {
					ageFootnote += ageFootnote.isEmpty ? astrologicalSign : " \(astrologicalSign)"
				}
				return ageFootnote.isEmpty ? nil : ageFootnote
			default: return nil
			}
		}
	}
}
