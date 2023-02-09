//
//  ExploreCategoryIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/06/2022.
//

/// A root object that stores information about an explore category identity resource.
public struct ExploreCategoryIdentity: IdentityResource, Hashable {
	// MARK: - Properties
	public var id: String

	public var type: String

	public var href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "explore"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: ExploreCategoryIdentity, rhs: ExploreCategoryIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}

