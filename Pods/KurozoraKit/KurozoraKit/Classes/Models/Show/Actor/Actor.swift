//
//  Actor.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/**
	A root object that stores information about an actor resource.
*/
public struct Actor: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the actor.
	public let attributes: Actor.Attributes

	/// The relationships belonging to the actor.
	public let relationships: Actor.Relationships?

	// MARK: - Functions
	public static func == (lhs: Actor, rhs: Actor) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
