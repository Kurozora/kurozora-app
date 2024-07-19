//
//  CharacterIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a character identity resource.
public struct CharacterIdentity: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "characters"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: CharacterIdentity, rhs: CharacterIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
