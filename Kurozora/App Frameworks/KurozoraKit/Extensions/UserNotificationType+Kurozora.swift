//
//  UserNotificationType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension UserNotificationType {
	// MARK: - Properties
	/// The string value of a user notification type.
	var stringValue: String {
		switch self {
		case .session:
			return L10n.newSession
		case .follower:
			return L10n.follower
		case .feedMessageReply, .feedMessageReShare:
			return L10n.message
		case .libraryImportFinished:
			return L10n.libraryImport
		case .subscriptionStatus:
			return L10n.subscriptionUpdate
		case .other:
			return L10n.other
		}
	}

	/// The image value of a user notification type cell.
	var iconValue: UIImage? {
		switch self {
		case .session:
            return .Icons.session
		case .follower:
            return .Icons.follower
		case .feedMessageReply, .feedMessageReShare:
            return .Icons.message
		case .libraryImportFinished:
            return .Icons.library
		case .subscriptionStatus:
            return .Icons.unlock
		case .other:
            return .Icons.notifications
		}
	}
}
