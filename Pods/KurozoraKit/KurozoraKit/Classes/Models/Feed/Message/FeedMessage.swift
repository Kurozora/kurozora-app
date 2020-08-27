//
//  FeedMessage.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

/**
	A root object that stores information about a feed message resource.
*/
public struct FeedMessage: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the feed message.
	public var attributes: FeedMessage.Attributes

	/// The relationships belonging to the feed message.
	public let relationships: FeedMessage.Relationships
}

