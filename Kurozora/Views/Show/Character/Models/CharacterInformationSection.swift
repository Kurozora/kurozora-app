//
//  CharacterInformationSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/**
	Set of available character information sections.
*/
enum CharacterInformationSection: Int, CaseIterable {
	// MARK: - Cases
	case debut
	case status
	case bloodType
	case favoriteFood
	case bustSize
	case waistSize
	case hipSize
	case height
	case age
	case birthDay
	case birthMonth
	case astrologicalSign

	// MARK: - Properties
	/// The string value of a character information section.
	var stringValue: String {
		switch self {
		case .debut:
			return "Debut"
		case .status:
			return "Status"
		case .bloodType:
			return "Blood Type"
		case .favoriteFood:
			return "Favorite Food"
		case .bustSize:
			return "Bust Size"
		case .waistSize:
			return "Waist Size"
		case .hipSize:
			return "Hip Size"
		case .height:
			return "Height"
		case .age:
			return "Age"
		case .birthDay:
			return "Birth Day"
		case .birthMonth:
			return "Birth Month"
		case .astrologicalSign:
			return "Astrological Sign"
		}
	}

	/// The cell identifier string of a character information section.
	var identifierString: String {
		switch self {
		case .debut:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .status:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .bloodType:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .favoriteFood:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .bustSize:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .waistSize:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .hipSize:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .height:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .age:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .birthDay:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .birthMonth:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .astrologicalSign:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		}
	}

	// MARK: - Functions
	/**
		Returns the required information from the given object.

		- Parameter character: The object used to extract the infromation from.

		Returns: the required information from the given object.
	*/
	func information(from character: Character) -> String {
		switch self {
		case .debut:
			if let debut = character.attributes.debut {
				return debut
			}
		case .status:
			if let status = character.attributes.status {
				return status
			}
		case .bloodType:
			if let bloodType = character.attributes.bloodType {
				return bloodType
			}
		case .favoriteFood:
			if let favoriteFood = character.attributes.favoriteFood {
				return favoriteFood
			}
		case .bustSize:
			if let bustSize = character.attributes.bustSize, bustSize != 0 {
				return "\(bustSize)"
			}
		case .waistSize:
			if let waistSize = character.attributes.waistSize, waistSize != 0 {
				return "\(waistSize)"
			}
		case .hipSize:
			if let hipSize = character.attributes.hipSize, hipSize != 0 {
				return "\(hipSize)"
			}
		case .height:
			if let height = character.attributes.height {
				return height
			}
		case .age:
			if let age = character.attributes.age, age != 0 {
				return "\(age)"
			}
		case .birthDay:
			if let birthDay = character.attributes.birthDay, birthDay != 0 {
				return "\(birthDay)"
			}
		case .birthMonth:
			if let birthMonth = character.attributes.birthMonth, birthMonth != 0 {
				return "\(birthMonth)"
			}
		case .astrologicalSign:
			if let astrologicalSign = character.attributes.astrologicalSign {
				return astrologicalSign
			}
		}
		return "-"
	}
}
