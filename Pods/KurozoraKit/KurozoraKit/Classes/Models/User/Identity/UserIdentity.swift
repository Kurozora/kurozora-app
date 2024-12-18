//
//  UserIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/05/2022.
//

/// A root object that stores information about a user identity resource.
public struct UserIdentity: IdentityResource, Hashable {
	// MARK: - Properties
	public var id: String

	public var type: String

	public var href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "users"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: UserIdentity, rhs: UserIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
