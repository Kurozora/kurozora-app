//
//  FeedMessageIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/12/2022.
//

/// A root object that stores information about a feed message identity resource.
public struct FeedMessageIdentity: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "feed-messages"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: FeedMessageIdentity, rhs: FeedMessageIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
