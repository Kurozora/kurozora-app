//
//  RecapItem.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

/// A root object that stores information about a recap item resource.
public struct RecapItem: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the recap item.
	public let attributes: RecapItem.Attributes

	/// The relationships belonging to the recap item.
	public let relationships: RecapItem.Relationships?

	// MARK: - Functions
	public static func == (lhs: RecapItem, rhs: RecapItem) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
