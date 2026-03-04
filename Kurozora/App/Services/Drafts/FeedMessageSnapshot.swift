//
//  FeedMessageSnapshot.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A lightweight, Codable snapshot of a feed message used to persist parent context for reply/reshare drafts.
struct FeedMessageSnapshot: Codable {
	/// The feed message's server ID.
	let messageID: String

	/// The message body in markdown format.
	let contentMarkdown: String

	/// The author's username.
	let authorUsername: String

	/// The author's slug.
	let authorSlug: String

	/// The author's profile image URL string.
	let authorProfileImageURL: String?

	/// The original post date.
	let createdAt: Date

	/// Whether the message is flagged as NSFW.
	let isNSFW: Bool

	/// Whether the message is flagged as a spoiler.
	let isSpoiler: Bool

	/// Creates a snapshot from a live `FeedMessage`.
	///
	/// - Parameter feedMessage: The feed message to snapshot.
	init(from feedMessage: FeedMessage) {
		let author = feedMessage.relationships.users.data.first

		self.messageID = String(describing: feedMessage.id)
		self.contentMarkdown = feedMessage.attributes.contentMarkdown
		self.authorUsername = author?.attributes.username ?? ""
		self.authorSlug = author?.attributes.slug ?? ""
		self.authorProfileImageURL = author?.attributes.profile?.url
		self.createdAt = feedMessage.attributes.createdAt
		self.isNSFW = feedMessage.attributes.isNSFW
		self.isSpoiler = feedMessage.attributes.isSpoiler
	}
}
