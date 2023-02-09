//
//  Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

/// A root object that stores information about a cast resource.
public struct Cast: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes, relationships
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the show.
	public var attributes: Cast.Attributes

	/// The relationships belonging to the show.
	public let relationships: Cast.Relationships

	// MARK: - Functions
	public static func == (lhs: Cast, rhs: Cast) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
