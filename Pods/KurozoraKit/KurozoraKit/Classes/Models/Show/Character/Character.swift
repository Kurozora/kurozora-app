//
//  Character.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/**
	A root object that stores information about a character resource.
*/
public struct Character: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the character.
	public let attributes: Character.Attributes

	/// The relationships belonging to the character.
	public let relationships: Character.Relationships?
}
