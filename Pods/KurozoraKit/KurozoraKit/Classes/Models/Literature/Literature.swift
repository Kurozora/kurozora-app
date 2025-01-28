//
//  Literature.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

/// A root object that stores information about a literature resource.
public final class Literature: IdentityResource, Hashable, @unchecked Sendable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the literature.
	public var attributes: Literature.Attributes

	/// The relationships belonging to the literature.
	public let relationships: Literature.Relationships?

	// MARK: - Functions
	public static func == (lhs: Literature, rhs: Literature) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
