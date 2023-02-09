//
//  Theme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/01/2019.
//

/// A root object that stores information about a theme resource.
public struct Theme: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the genre.
	public let attributes: Theme.Attributes

	// MARK: - Functions
	public static func == (lhs: Theme, rhs: Theme) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
