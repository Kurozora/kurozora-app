//
//  FeedMessageAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

extension FeedMessage {
	/**
		A root object that stores information about a single feed message, such as the message's body, and whether it's a spoiler or NSFW.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The body of the feed message.
		public let body: String

		/// The reply count of the feed message.
		public let replyCount: Int

		/// The re-share count of the feed message.
		public let reShareCount: Int

		/// The metrics of the feed message.
		public let metrics: FeedMessage.Attributes.Metrics

		/// Whether the feed message is a reply.
		public let isReply: Bool

		/// Whether the feed message is a re-share
		public let isReShare: Bool

		/// Whether the feed message is locked.
		public let isNSFW: Bool

		/// The count of replies on the feed message.
		public let isSpoiler: Bool

		/// The date the feed message was created at.
		public let createdAt: String
	}
}
