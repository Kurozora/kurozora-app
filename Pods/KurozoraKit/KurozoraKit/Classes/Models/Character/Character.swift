//
//  Character.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about a character resource.
public struct Character: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the character.
	public let attributes: Character.Attributes

	/// The relationships belonging to the character.
	public let relationships: Character.Relationships?

	// MARK: - Functions
	public static func == (lhs: Character, rhs: Character) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
