//
//  ExploreCategory.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2018.
//

/// A root object that stores information about an explore category resource.
public struct ExploreCategory: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the explore category.
	public let attributes: ExploreCategory.Attributes

	/// The relationships belonging to the explore category.
	public let relationships: ExploreCategory.Relationships

	// MARK: - Functions
	public static func == (lhs: ExploreCategory, rhs: ExploreCategory) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
