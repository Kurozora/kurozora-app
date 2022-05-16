//
//  CharacterIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a character identity resource.
public class CharacterIdentity: IdentityResource, Hashable {
	public let id: Int

	public let type: String

	public let href: String

	// MARK: - Initializers
	public init(id: Int) {
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
