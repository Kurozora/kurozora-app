//
//  StaffIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/10/2023.
//

/// A root object that stores information about a staff identity resource.
public struct StaffIdentity: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "staff"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: StaffIdentity, rhs: StaffIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
