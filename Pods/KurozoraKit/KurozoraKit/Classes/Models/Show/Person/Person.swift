//
//  Person.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/**
	A root object that stores information about a person resource.
*/
public struct Person: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the person.
	public let attributes: Person.Attributes

	/// The relationships belonging to the person.
	public let relationships: Person.Relationships?

	// MARK: - Functions
	public static func == (lhs: Person, rhs: Person) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
