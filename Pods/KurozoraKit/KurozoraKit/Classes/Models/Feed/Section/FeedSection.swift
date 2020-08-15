//
//  FeedSection.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

/**
	A root object that stores information about a feed section resource.
*/
public struct FeedSection: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the feed section.
	public let attributes: FeedSection.Attributes
}
