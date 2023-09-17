//
//  Review.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/07/2023.
//

/// A root object that stores information about a review resource.
public class Review: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	// MARK: - Properties
	/// The attributes belonging to the show.
	public var attributes: Review.Attributes

	/// The relationships belonging to the show.
	public let relationships: Review.Relationships?

	// MARK: - Functions
	public static func == (lhs: Review, rhs: Review) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
