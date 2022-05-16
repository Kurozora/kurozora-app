//
//  CharacterInformation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// Set of available character information types.
enum CharacterInformation: Int, CaseIterable {
	// MARK: - Cases
	case debut = 0
	case age
	case measurments
	case characteristics

	// MARK: - Properties
	/// The string value of a character information types.
	var stringValue: String {
		switch self {
		case .debut:
			return Trans.debut
		case .age:
			return Trans.age
		case .measurments:
			return Trans.measurments
		case .characteristics:
			return Trans.characteristics
		}
	}

	/// The image value of a character information type.
	var imageValue: UIImage? {
		switch self {
		case .debut:
			return UIImage(systemName: "star")
		case .age:
			return UIImage(systemName: "calendar")
		case .measurments:
			return UIImage(systemName: "ruler")
		case .characteristics:
			return UIImage(systemName: "list.bullet.rectangle")
		}
	}

	/// The cell identifier string of a character information types.
	var identifierString: String {
		switch self {
		case .debut:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .age:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .measurments:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .characteristics:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		}
	}

	// MARK: - Functions
	/// Returns the required information from the given object.
	///
	/// - Parameter character: The object used to extract the infromation from.
	///
	/// Returns: the required information from the given object.
	func information(from character: Character) -> String? {
		switch self {
		case .debut:
			if let debut = character.attributes.debut {
				return debut
			}
		case .age:
			if let age = character.attributes.age, !age.isEmpty {
				return age
			}
		case .measurments:
			var measurments = ""
			if let height = character.attributes.height {
				measurments += "Height: \(height)"
			}

			if let weight = character.attributes.weight {
				measurments += "Weight: \(weight)"
			}

			if let bustSize = character.attributes.bustSize, bustSize != 0 {
				measurments +=  measurments.isEmpty ? "Bust: " : "\nBust: "
				measurments += "\(bustSize)"
			}

			if let waistSize = character.attributes.waistSize, waistSize != 0 {
				measurments +=  measurments.isEmpty ? "Waist: " : "\nWaist: "
				measurments += "\(waistSize)"
			}

			if let hipSize = character.attributes.hipSize, hipSize != 0 {
				measurments +=  measurments.isEmpty ? "Hip: " : "\nHip: "
				measurments += "\(hipSize)"
			}
			return measurments
		case .characteristics:
			var characteristics = ""
			if let bloodType = character.attributes.bloodType {
				characteristics += characteristics.isEmpty ? "Blood Type: " : "\nBlood Type: "
				characteristics += bloodType
			}

			if let favoriteFood = character.attributes.favoriteFood {
				characteristics += characteristics.isEmpty ? "Favorite Food: " : "\nFavorite Food: "
				characteristics += favoriteFood
			}
			return characteristics
		}
		return nil
	}

	/// Returns the required primary information from the given object.
	///
	/// - Parameter character: The object used to extract the infromation from.
	///
	/// - Returns: the required primary information from the given object.
	func primaryInformation(from character: Character) -> String? {
		switch self {
		default: return nil
		}
	}

	/// Returns the required secondary information from the given object.
	///
	/// - Parameter character: The object used to extract the infromation from.
	///
	/// - Returns: the required secondary information from the given object.
	func secondaryInformation(from character: Character) -> String? {
		switch self {
		default: return nil
		}
	}

	/// Returns the required primary image from the given object.
	///
	/// - Parameter character: The object used to extract the infromation from.
	///
	/// - Returns: the required primary image from the given object.
	func primaryImage(from character: Character) -> UIImage? {
		switch self {
		default: return nil
		}
	}

	/// Returns the footnote from the given object.
	///
	/// - Parameter character: The object used to extract the footnote from.
	///
	/// - Returns: the footnote from the given object.
	func footnote(from character: Character) -> String? {
		switch self {
		case .debut:
			guard let status = character.attributes.status else { return nil }
			return "The character is \(status)."
		case .age:
			var ageFootnote = ""
			if let birthdate = character.attributes.birthdate, !birthdate.isEmpty {
				ageFootnote += birthdate
			}

			if let astrologicalSign = character.attributes.astrologicalSign {
				ageFootnote += ageFootnote.isEmpty ? astrologicalSign : " \(astrologicalSign)"
			}
			return ageFootnote.isEmpty ? nil : ageFootnote
		default: return nil
		}
	}
}
