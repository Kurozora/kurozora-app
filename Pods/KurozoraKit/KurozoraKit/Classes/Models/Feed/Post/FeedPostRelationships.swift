//
//  FeedPostRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

extension FeedPost {
	/**
		A root object that stores information about feed post relationships, such as the user it belongs to.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The user object the feed post belongs to.
		public let user: UserResponse
	}
}

