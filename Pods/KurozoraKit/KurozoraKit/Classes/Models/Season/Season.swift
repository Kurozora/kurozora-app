//
//  Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about a season resource.
public class Season: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the season.
	public var attributes: Season.Attributes

	// MARK: - Functions
	public static func == (lhs: Season, rhs: Season) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
