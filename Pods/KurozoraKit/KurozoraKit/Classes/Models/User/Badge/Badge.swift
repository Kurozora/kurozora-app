//
//  Badge.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 23/08/2019.
//

/// A root object that stores information about a badge resource.
public struct Badge: Codable, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, attributes
	}

	// MARK: - Properties
	/// The id of the resource.
	public let id: String

	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the badge.
	public var attributes: Badge.Attributes

	// MARK: - Functions
	public static func == (lhs: Badge, rhs: Badge) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
