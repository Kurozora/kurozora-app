//
//  FeedPostAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension FeedPost {
	/**
		A root object that stores information about a single feed post, such as the posts's content, reply count, and share count.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The content of the post.
		public let content: String

		/// The date fo the post was created at.
		public let createdAt: String

		/// The reply count of the post.
		public let replyCount: Int

		/// The share count of the post.
		public let shareCount: Int

		/// The hearts count of the post.
		public let heartsCount: Int
	}
}
