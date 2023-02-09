//
//  SeasonIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/02/2022.
//

/// A root object that stores information about a season identity resource.
public struct SeasonIdentity: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "seasons"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: SeasonIdentity, rhs: SeasonIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
