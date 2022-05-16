//
//  FeedMessageAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

extension FeedMessage {
	/// A root object that stores information about a single feed message, such as the message's body, and whether it's a spoiler or NSFW.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The body of the feed message.
		public var body: String

		/// The metrics of the feed message.
		public var metrics: FeedMessage.Attributes.Metrics

		/// Whether the feed message is hearted by the authenticated user.
		public var isHearted: Bool?

		/// Whether the feed message is a reply.
		public let isReply: Bool

		/// Whether the feed message is a re-share.
		public let isReShare: Bool

		/// Whether the feed message is a re-shared by the authenticated user.
		public let isReShared: Bool

		/// Whether the feed message is NSFW.
		public var isNSFW: Bool

		/// Whether the feed message is spoiler.
		public var isSpoiler: Bool

		/// The date the feed message was created at.
		public let createdAt: Date
	}
}

// MARK: - Helpers
extension FeedMessage.Attributes {
	// MARK: - Functions
	/// Updates the message's attribute with the given `FeedMessageUpdate` object.
	///
	/// - Parameter feedMessageUpdate: The object containing the new attribute values.
	public mutating func update(using feedMessageUpdate: FeedMessageUpdate) {
		self.body = feedMessageUpdate.body ?? self.body
		self.isNSFW = feedMessageUpdate.isNSFW ?? self.isNSFW
		self.isSpoiler = feedMessageUpdate.isSpoiler ?? self.isSpoiler

		if let isHearted = feedMessageUpdate.isHearted {
			self.isHearted = isHearted

			if isHearted {
				self.metrics.heartCount += 1
			} else {
				self.metrics.heartCount -= 1
			}
		}
	}
}
