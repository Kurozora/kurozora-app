//
//  FeedMessageUpdateRequest.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 6/12/2022.
//

/// A root object that stores information about a feed message update request.
public struct FeedMessageUpdateRequest {
	// MARK: - Properties
	/// The identity of the feed message being updated.
	public let feedMessageIdentity: FeedMessageIdentity

	/// The content of the feed message.
	public let content: String

	/// Whether the message contains NSFW material.
	public let isNSFW: Bool

	/// Whether the message contains spoiler material.
	public let isSpoiler: Bool

	// MARK: - Initializers
	/// Initialize a new instance of `FeedMessageUpdateRequest` to request updating a feed message.
	///
	/// - Parameters:
	///    - feedMessageIdentity: The identity of the feed message being updated.
	///    - content: The new content of the feed message.
	///    - isNSFW: Whether the message contains NSFW material.
	///    - isSpoiler: Whether the message contains spoiler material.
	public init(feedMessageIdentity: FeedMessageIdentity, content: String, isNSFW: Bool, isSpoiler: Bool) {
		self.feedMessageIdentity = feedMessageIdentity
		self.content = content
		self.isNSFW = isNSFW
		self.isSpoiler = isSpoiler
	}
}
