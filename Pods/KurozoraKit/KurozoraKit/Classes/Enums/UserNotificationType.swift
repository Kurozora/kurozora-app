//
//  UserNotificationType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2022.
//

/// The set of available user notification types.
///
/// - `session`: the notification has a `session` type and thus has the sessions style.
/// - `follower`: the notification has a `follower` type and thus has the follower style.
/// - `feedMessageReply`: the notification has a `feedMessageReply` type and thus has the message style.
/// - `feedMessageReShare`: the notification has a `feedMessageReShare` type and thus has the message style.
/// - `libraryImportFinished`: the notification has a `libraryImportFinished` type and thus has the import style.
/// - `subscriptionStatus`: the notification has a `subscriptionStatus` type and thus the subscription style.
/// - `other`: the notification has no specific type and thus has the default style.
///
/// - Tag: UserNotificationType
public enum UserNotificationType: String, Codable, Sendable {
	// MARK: - Cases
	/// Indicates that the notification has a `session` type and thus has the sessions style.
	case session = "NewSession"

	/// Indicates that the notification has a `follower` type and thus has the follower style.
	case follower = "NewFollower"

	/// Indicates that the notification has a `feedMessageReply` type and thus has the message style.
	case feedMessageReply = "NewFeedMessageReply"

	/// Indicates that the notification has a `feedMessageReShare` type and thus has the message style.
	case feedMessageReShare = "NewFeedMessageReShare"

	/// Indicates that the notification has a `libraryImportFinished` type and thus thas the import style.
	case libraryImportFinished = "LibraryImportFinished"

	/// Indicates that the notification has a `subscriptionStatus` type and thus the subscription style.
	case subscriptionStatus = "SubscriptionStatus"

	/// Indicates that the notification has no specific type and thus has the default style.
	case other
}
