//
//  FeedMessageRequest.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 6/12/2022.
//

/// A root object that stores information about a feed message request.
public struct FeedMessageRequest {
	// MARK: - Properties
	/// The content of the feed message.
	public let content: String

	/// The identity of the parent message this message is related to.
	public let parentIdentity: FeedMessageIdentity?

	/// Whether the message is a reply to another message.
	public let isReply: Bool?

	/// Whether the message is a re-share of another message.
	public let isReShare: Bool?

	/// Whether the message contains NSFW material.
	public let isNSFW: Bool

	/// Whether the message contains spoiler material.
	public let isSpoiler: Bool

	// MARK: - Initializers
	/// Initialize a new instance of `FeedMessageRequest` to request posting a new feed message.
	///
	/// - Parameters:
	///    - content: The new content of the feed message.
	///    - parentIdentity: The identity of the parent message this message is related to.
	///    - isReply: Whether the message is a reply to another message. Required if `parentIdentity` is specified.
	///    - isReShare: Whether the message is a re-share of another message. Required if `parentIdentity` is specified.
	///    - isNSFW: Whether the message contains NSFW material.
	///    - isSpoiler: Whether the message contains spoiler material.
	public init(content: String, parentIdentity: FeedMessageIdentity?, isReply: Bool?, isReShare: Bool?, isNSFW: Bool, isSpoiler: Bool) {
		self.content = content
		self.parentIdentity = parentIdentity
		self.isReply = isReply
		self.isReShare = isReShare
		self.isNSFW = isNSFW
		self.isSpoiler = isSpoiler
	}
}
