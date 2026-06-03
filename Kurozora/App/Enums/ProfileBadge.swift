//
//  ProfileBadge.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum ProfileBadge {
	// MARK: - Cases
	case newUser(user: User, isCurrentUser: Bool)
	case developer(username: String)
	case earlySupporter(username: String)
	case staff(username: String)
	case pro(username: String)
	case subscriber(username: String, subscribedAt: Date)
	case verified(username: String)

	// MARK: - Properties
	/// The title value of a profile badge.
	var title: String {
		switch self {
		case .newUser:
			return L10n.badgeNewUserTitle
		case .developer:
			return L10n.badgeDeveloperTitle
		case .earlySupporter:
			return L10n.badgeEarlySupporterTitle
		case .staff:
			return L10n.badgeStaffTitle
		case .pro:
			return "Kurozora Pro"
		case .subscriber:
			return "Kurozora+"
		case .verified:
			return L10n.badgeVerifiedTitle
		}
	}

	/// The description value of a profile badge.
	var description: String {
		switch self {
		case .newUser(let user, let isCurrentUser):
			return isCurrentUser ? L10n.badgeNewUserCurrentUserDescription : L10n.badgeNewUserDescription(user.attributes.username)
		case .developer(let username):
			return L10n.badgeDeveloperDescription(username)
		case .earlySupporter(let username):
			return L10n.badgeEarlySupporterDescription(username)
		case .staff(let username):
			return L10n.badgeStaffDescription(username)
		case .pro(let username):
			return L10n.badgeProDescription(username)
		case .subscriber(let username, let subscribedAt):
			return L10n.badgeSubscriberDescription(username, since: subscribedAt.formatted(date: .abbreviated, time: .omitted))
		case .verified(let username):
			return L10n.badgeVerifiedDescription(username)
		}
	}

	/// The button title value of a profile badge.
	var buttonTitle: String? {
		switch self {
		case .newUser(_, let isCurrentUser):
			return isCurrentUser ? nil : L10n.badgeMentionUser
		case .developer:
			return L10n.badgeBecomeDeveloper
		case .earlySupporter:
			return nil
		case .staff:
			return L10n.badgeJoinStaff
		case .pro:
			return L10n.badgeBecomePro
		case .subscriber:
			return L10n.becomeASubscriber
		case .verified:
			return L10n.badgeGetVerified
		}
	}

	/// The image value of a profile badge.
	var image: UIImage? {
		switch self {
		case .newUser:
            return .Badges.beginnerShield
		case .developer:
            return .Badges.hammerApp
		case .earlySupporter:
            return .Badges.birdTriangle
		case .staff:
            return .Badges.sakuraShield
		case .pro:
            return .Badges.rocketCircle
		case .subscriber(_, let subscribedAt):
			let numberOfMonths = Date().months(from: subscribedAt)

			if numberOfMonths >= 24 {
                return .Badges.twentyFourMonths
			} else if numberOfMonths >= 18 {
                return .Badges.eighteenMonths
			} else if numberOfMonths >= 15 {
                return .Badges.fifteenMonths
			} else if numberOfMonths >= 12 {
                return .Badges.twelveMonths
			} else if numberOfMonths >= 9 {
                return .Badges.nineMonths
			} else if numberOfMonths >= 6 {
                return .Badges.sixMonths
			} else if numberOfMonths >= 3 {
                return .Badges.threeMonths
			} else if numberOfMonths >= 2 {
                return .Badges.twoMonths
			} else {
                return .Badges.oneMonth
			}
		case .verified:
            return .Badges.checkmarkSeal
		}
	}
}
