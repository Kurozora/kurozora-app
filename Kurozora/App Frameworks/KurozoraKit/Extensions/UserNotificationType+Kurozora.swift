//
//  UserNotificationType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit

extension UserNotificationType {
	// MARK: - Properties
	/// The string value of a user notification type.
	var stringValue: String {
		switch self {
		case .session:
			return Trans.newSession
		case .follower:
			return Trans.follower
		case .feedMessageReply, .feedMessageReShare:
			return Trans.message
		case .libraryImportFinished:
			return Trans.libraryImport
		case .subscriptionStatus:
			return Trans.subscriptionUpdate
		case .other:
			return Trans.other
		}
	}

	/// The image value of a user notification type cell.
	var iconValue: UIImage? {
		switch self {
		case .session:
			return R.image.icons.session()
		case .follower:
			return R.image.icons.follower()
		case .feedMessageReply, .feedMessageReShare:
			return R.image.icons.message()
		case .libraryImportFinished:
			return R.image.icons.library()
		case .subscriptionStatus:
			return R.image.icons.unlock()
		case .other:
			return R.image.icons.notifications()
		}
	}
}
