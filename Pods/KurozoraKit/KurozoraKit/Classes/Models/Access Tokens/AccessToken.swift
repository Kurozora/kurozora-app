//
//  AccessToken.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/11/2021.
//

/// A root object that stores information about a collection of access tokens.
public struct AccessToken: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes, relationships
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the access token.
	public let attributes: AccessToken.Attributes

	/// The relationships belonging to the access token.
	public let relationships: AccessToken.Relationships

	// MARK: - Functions
	public static func == (lhs: AccessToken, rhs: AccessToken) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
