//
//  Person.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about a person resource.
public final class Person: IdentityResource, Hashable, @unchecked Sendable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the person.
	public var attributes: Person.Attributes

	/// The relationships belonging to the person.
	public let relationships: Person.Relationships?

	// MARK: - Functions
	public static func == (lhs: Person, rhs: Person) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
