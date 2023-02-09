//
//  FeedMessage.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

/// A root object that stores information about a feed message resource.
public class FeedMessage: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes, relationships
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the feed message.
	public var attributes: FeedMessage.Attributes

	/// The relationships belonging to the feed message.
	public let relationships: FeedMessage.Relationships

	// MARK: - Functions
	public static func == (lhs: FeedMessage, rhs: FeedMessage) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
