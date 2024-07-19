//
//  Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about a show resource.
public class Show: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the show.
	public var attributes: Show.Attributes

	/// The relationships belonging to the show.
	public let relationships: Show.Relationships?

	// MARK: - Functions
	public static func == (lhs: Show, rhs: Show) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
