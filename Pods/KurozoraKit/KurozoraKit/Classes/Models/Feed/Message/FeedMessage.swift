//
//  FeedMessage.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

/// A root object that stores information about a feed message resource.
public final class FeedMessage: IdentityResource, Hashable, @unchecked Sendable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the feed message.
	public var attributes: FeedMessage.Attributes

	/// The relationships belonging to the feed message.
	public let relationships: FeedMessage.Relationships

	// MARK: - Functions
	public static func == (lhs: FeedMessage, rhs: FeedMessage) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}

// MARK: - Helpers
extension FeedMessage {
	/// The maximum character limit for a feed message.
	///
	/// The character limit is determined by the user's account status.
	/// The character limit is as follows:
	/// - 280 characters for normal users.
	/// - 500 characters for pro users.
	/// - 1000 characters for subscribed users.
	public static var maxCharacterLimit: Int {
		if User.isSubscribed {
			return 1000
		} else if User.isPro {
			return 500
		}

		return 280
	}
}
