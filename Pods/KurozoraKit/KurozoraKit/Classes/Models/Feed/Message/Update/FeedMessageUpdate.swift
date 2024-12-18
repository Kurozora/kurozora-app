//
//  FeedMessageUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/11/2021.
//

/// A root object that stores information about a feed message update resource.
public struct FeedMessageUpdate: Codable {
	// MARK: - Properties
	/// The content of the feed message.
	public let content: String?

	/// The HTML content of the feed message.
	public let contentHTML: String?

	/// The Markdown content of the feed message.
	public let contentMarkdown: String?

	/// Whether the feed message is hearted by the authenticated user.
	public var isHearted: Bool?

	/// Whether the feed message is locked.
	public let isNSFW: Bool?

	/// Whether the feed message is pinned.
	public let isPinned: Bool

	/// Whether the feed message is spoiler.
	public let isSpoiler: Bool?
}
