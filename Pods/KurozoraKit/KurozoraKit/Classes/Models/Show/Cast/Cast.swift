//
//  Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

/**
	A root object that stores information about a cast resource.
*/
public struct Cast: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the show.
	public var attributes: Cast.Attributes

	/// The relationships belonging to the show.
	public let relationships: Cast.Relationships

	// MARK: - Functions
	public static func == (lhs: Cast, rhs: Cast) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
