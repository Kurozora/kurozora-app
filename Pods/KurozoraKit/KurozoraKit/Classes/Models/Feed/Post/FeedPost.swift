//
//  FeedPost.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/**
	A root object that stores information about a feed post resource.
*/
public struct FeedPost: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the feed post.
	public let attributes: FeedPost.Attributes

	/// The relationships belonging to the feed post.
	public let relationships: FeedPost.Relationships
}
