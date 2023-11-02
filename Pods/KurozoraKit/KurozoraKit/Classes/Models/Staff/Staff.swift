//
//  Staff.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 15/06/2021.
//

/// A root object that stores information about a staff resource.
public struct Staff: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes, relationships
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the staff.
	public let attributes: Staff.Attributes

	/// The relationships belonging to the staff.
	public let relationships: Staff.Relationships

	// MARK: - Functions
	public static func == (lhs: Staff, rhs: Staff) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
