//
//  CharacterElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single character, such as the character's name, blood type, and hight.
*/
public class CharacterElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the character.
	public let id: Int?

	/// The name of the character.
	public let name: String?

	/// The biogrpahy of the character.
	public let about: String?

	/// The string to an image url of the chracter.
	public let imageString: String?

	/// The debut information of the character,
	public let debut: String?

	/// The status of the character.
	public let status: String?

	/// The blood type of the character.
	public let bloodType: String?

	/// The favorite food of the character.
	public let favoriteFood: String?

	/// The bust size of the character.
	public let bustSize: Double?

	/// The waist size of the character.
	public let waistSize: Double?

	/// The hip size of the character.
	public let hipSize: Double?

	/// The height of the character.
	public let height: String?

	/// The age of the character.
	public let age: Int?

	/// The day the character was born.
	public let birthDay: Int?

	/// The month the character was born.
	public let birthMonth: Int?

	/// The astronomical sign of the character.
	public let astrologicalSign: String?

	// MARK: - Initializers
	/// Initializes an empty instance of `CharacterElement`.
	internal init() {
		self.id = nil
		self.name = nil
		self.about = nil
		self.imageString = nil
		self.debut = nil
		self.status = nil
		self.bloodType = nil
		self.favoriteFood = nil
		self.bustSize = nil
		self.waistSize = nil
		self.hipSize = nil
		self.height = nil
		self.age = nil
		self.birthDay = nil
		self.birthMonth = nil
		self.astrologicalSign = nil
	}

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.about = json["about"].stringValue
		self.imageString = json["image"].stringValue
		self.debut = json["debut"].stringValue
		self.status = json["status"].stringValue
		self.bloodType = json["blood_type"].stringValue
		self.favoriteFood = json["favorite_food"].stringValue
		self.bustSize = json["bust"].doubleValue
		self.waistSize = json["waist"].doubleValue
		self.hipSize = json["hip"].doubleValue
		self.height = json["height"].stringValue
		self.age = json["age"].intValue
		self.birthDay = json["birth_day"].intValue
		self.birthMonth = json["birth_month"].intValue
		self.astrologicalSign = json["astrological_sign"].stringValue
	}
}
