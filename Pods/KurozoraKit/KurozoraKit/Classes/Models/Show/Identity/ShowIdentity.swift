//
//  ShowIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/07/2021.
//

/// A root object that stores information about a show identity resource.
public struct ShowIdentity: IdentityResource, Hashable {
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
		self.type = "shows"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: ShowIdentity, rhs: ShowIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
