//
//  FeedMessageRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

extension FeedMessage {
	/// A root object that stores information about feed message relationships, such as the user it belongs to.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The user object the feed message belongs to.
		public let users: UserResponse

		/// The parent message object the feed message belongs to.
		public let parent: FeedMessageResponse?

		/// The message object the feed message belongs to.
		public let messages: FeedMessageResponse?
	}
}
