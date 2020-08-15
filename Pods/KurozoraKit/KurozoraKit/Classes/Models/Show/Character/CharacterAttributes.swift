//
//  CharacterElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

extension Character {
	/**
		A root object that stores information about a single character, such as the character's name, blood type, and hight.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The name of the character.
		public let name: String

		/// The biogrpahy of the character.
		public let about: String?

		/// The link to an image of the chracter.
		public let imageURL: String?

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
	}
}
