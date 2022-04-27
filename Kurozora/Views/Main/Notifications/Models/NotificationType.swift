//
//  NotificationType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

enum KNotification {
	/// List of custom notification types.
	enum CustomType: String {
		/// Indicates that the notification has no specific type and thus has the default style.
		case other

		/// Indicates that the notification has a `session` type and thus has the sessions style.
		case session = "NewSession"

		/// Indicates that the notification has a `follower` type and thus has the follower style.
		case follower = "NewFollower"

		/// Indicates that the notification has a `newFeedMessageReply` type and thus has the message style.
		case newFeedMessageReply = "NewFeedMessageReply"

		/// Indicates that the notification has a `newFeedMessageReShare` type and thus has the message style.
		case newFeedMessageReShare = "NewFeedMessageReShare"

		/// Indicates that the notification has a `malImport` type and thus thas the import style.
		case malImport = "MALImportFinished"

		/// Indicates that the notification has a `subscriptionStatus` type and thus the subscription style.
		case subscriptionStatus = "SubscriptionStatus"

		/// The string value of a notification type.
		var stringValue: String {
			switch self {
			case .other:
				return "Other"
			case .session:
				return "New Session"
			case .follower:
				return "Follower"
			case .newFeedMessageReply, .newFeedMessageReShare:
				return "Message"
			case .malImport:
				return "Library Import"
			case .subscriptionStatus:
				return "Subscription Update"
			}
		}

		/// The string value of a notification type cell.
		var identifierString: String {
			switch self {
			case .other:
				return R.reuseIdentifier.baseNotificationCell.identifier
			case .session:
				return R.reuseIdentifier.basicNotificationCell.identifier
			case .follower:
				return R.reuseIdentifier.iconNotificationCell.identifier
			case .newFeedMessageReply, .newFeedMessageReShare:
				return R.reuseIdentifier.iconNotificationCell.identifier
			case .malImport:
				return R.reuseIdentifier.basicNotificationCell.identifier
			case .subscriptionStatus:
				return R.reuseIdentifier.basicNotificationCell.identifier
			}
		}

		/// The image value of a notification type cell.
		var iconValue: UIImage? {
			switch self {
			case .other:
				return R.image.icons.notifications()
			case .session:
				return R.image.icons.session()
			case .follower:
				return R.image.icons.follower()
			case .newFeedMessageReply, .newFeedMessageReShare:
				return R.image.icons.message()
			case .malImport:
				return R.image.icons.library()
			case .subscriptionStatus:
				return R.image.icons.unlock()
			}
		}
	}
}
