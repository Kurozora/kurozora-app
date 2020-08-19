//
//  NotificationType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

enum KNotification {
	/**
		List of custom notification types.
	*/
	enum CustomType: String {
		/// Indicates that the notification has no specific type and thus has the default style.
		case other

		/// Indicates that the notification has a `session` type and thus has the sessions style.
		case session = "NewSession"

		/// Indicates that the notification has a `follower` type and thus has the follower style.
		case follower = "NewFollower"

		/// Indicates that the notification has a `message` type and thus has the message style.
		case message = "NewMessage"

		/// Indicates that the notification has a `malImport` type and thus thas the import style.
		case malImport = "MALImportFinished"

		/// The string value of a notification type.
		var stringValue: String {
			switch self {
			case .other:
				return "Other"
			case .session:
				return "New Session"
			case .follower:
				return "Follower"
			case .message:
				return "Message"
			case .malImport:
				return "Library Import"
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
			case .message:
				return R.reuseIdentifier.iconNotificationCell.identifier
			case .malImport:
				return R.reuseIdentifier.basicNotificationCell.identifier
			}
		}

		/// The color value of a notification type cell.
		var colorValue: UIColor {
			switch self {
			case .other:
				return #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
			case .session:
				return #colorLiteral(red: 0.006537661422, green: 0.4778559804, blue: 0.9984870553, alpha: 1)
			case .follower:
				return #colorLiteral(red: 0.8862745098, green: 0.7647058824, blue: 0, alpha: 1)
			case .message:
				return #colorLiteral(red: 0.1950947344, green: 0.7805534601, blue: 0.3488782048, alpha: 1)
			case .malImport:
				return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
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
			case .message:
				return R.image.icons.message()
			case .malImport:
				return R.image.icons.library()
			}
		}
	}
}
