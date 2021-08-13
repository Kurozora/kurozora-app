//
//  NotificationKind.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import Foundation
import UserNotifications

/**
	The list of available notification kind types.
*/
enum NotificationKind: Int, CaseIterable {
	// MARK: - Cases
	case newSession = 0
	case showUpdate
	case newFollower

	// MARK: - Properties
	/// The identifier value of a notification kind type.
	var identifierValue: String {
		switch self {
		case .newSession:
			return "NEW_SESSION"
		case .showUpdate:
			return "SHOW_UPDATE"
		case .newFollower:
			return "NEW_FOLLOW"
		}
	}

	/// The action value of a notification kind type.
	var actionValue: NotificationKind.Action {
		switch self {
		case .newSession:
			return .viewSessionDetails
		case .showUpdate:
			return .viewShowDetails
		case .newFollower:
			return .viewProfileDetails
		}
	}
}

// MARK: - Action
extension NotificationKind {
	/**
		The list of available notification action types.
	*/
	enum Action: Int, CaseIterable {
		// MARK: - Cases
		case viewSessionDetails = 0
		case viewShowDetails
		case viewProfileDetails

		// MARK: - Properties
		/// The identifier value of a notification action  type.
		var identifierValue: String {
			switch self {
			case .viewSessionDetails:
				return "VIEW_SESSION_DETAILS"
			case .viewShowDetails:
				return "VIEW_SHOW_DETAILS"
			case .viewProfileDetails:
				return "VIEW_PROFILE_DETAILS"
			}
		}

		/// The title value of a notification action  type.
		var titleValue: String {
			switch self {
			case .viewSessionDetails:
				return "View Sessions"
			case .viewShowDetails:
				return "View Show Details"
			case .viewProfileDetails:
				return "View Profile"
			}
		}

		/// The action value of a notification action type.
		var actionValue: [UNNotificationAction] {
			switch self {
			case .viewSessionDetails:
				let showSessionsAction = UNNotificationAction(identifier: self.identifierValue, title: self.titleValue, options: .foreground)
				return [showSessionsAction]
			case .viewShowDetails:
				let showUpdateAction = UNNotificationAction(identifier: self.identifierValue, title: self.titleValue, options: .foreground)
				return [showUpdateAction]
			case .viewProfileDetails:
				let newUserFollowAction = UNNotificationAction(identifier: self.identifierValue, title: self.titleValue, options: .foreground)
				return [newUserFollowAction]
			}
		}
	}
}
