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
	The set of available notification kind types.
*/
enum NotificationKind: Int, CaseIterable {
	// MARK: - Cases
	case newSession = 0
	case showUpdate
	case newFollower
	case feedMessageReply
	case feedMessageReShare

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
		case .feedMessageReply:
			return "NEW_FEED_MESSAGE_REPLY"
		case .feedMessageReShare:
			return "NEW_FEED_MESSSAGE_RESAHRE"
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
		case .feedMessageReply:
			return .viewFeedMessageReply
		case .feedMessageReShare:
			return .viewFeedMessageReShare
		}
	}
}

// MARK: - Action
extension NotificationKind {
	/**
		The set of available notification action types.
	*/
	enum Action: Int, CaseIterable {
		// MARK: - Cases
		case viewSessionDetails = 0
		case viewShowDetails
		case viewProfileDetails
		case viewFeedMessageReply
		case viewFeedMessageReShare

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
			case .viewFeedMessageReply:
				return "VIEW_FEED_MESSAGE_REPLY"
			case .viewFeedMessageReShare:
				return "VIEW_FEED_MESSAGE_RESHARE"
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
			case .viewFeedMessageReply:
				return "View Message Reply"
			case .viewFeedMessageReShare:
				return "View Message Re-Share"
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
			case .viewFeedMessageReply:
				let newFeedMessageReplyAction = UNNotificationAction(identifier: self.identifierValue, title: self.titleValue, options: .foreground)
				return [newFeedMessageReplyAction]
			case .viewFeedMessageReShare:
				let newFeedMessageReShareAction = UNNotificationAction(identifier: self.identifierValue, title: self.titleValue, options: .foreground)
				return [newFeedMessageReShareAction]
			}
		}
	}
}
