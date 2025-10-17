//
//  ProfileBadge.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

enum ProfileBadge {
	// MARK: - Cases
	case newUser(username: String, isCurrentUser: Bool)
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
			return "I'm new here!"
		case .developer:
			return "Active Developer"
		case .earlySupporter:
			return "Early Supporter"
		case .staff:
			return "Staff"
		case .pro:
			return "Kurozora Pro"
		case .subscriber:
			return "Kurozora+"
		case .verified:
			return "Verified"
		}
	}

	/// The description value of a profile badge.
	var description: String {
		switch self {
		case .newUser(let username, let isCurrentUser):
			return isCurrentUser ? "Welcome to Kurozora! Introduce youself to get started (^_^)/" : "\(username) is new to Kurozora. Say hi to them (^o^)/"
		case .developer(let username):
			return "\(username) is an active developer."
		case .earlySupporter(let username):
			return "\(username) is an early supporter of Kurozora."
		case .staff(let username):
			return "\(username) is a staff member."
		case .pro(let username):
			return "\(username) is a Pro user."
		case .subscriber(let username, let subscribedAt):
			return "\(username) is a Kurozora+ subscriber since \(subscribedAt.formatted(date: .abbreviated, time: .omitted))."
		case .verified(let username):
			return "\(username) is verified because they are notable in animators, voice actors, entertainment studios, or another designated category."
		}
	}

	/// The button title value of a profile badge.
	var buttonTitle: String? {
		switch self {
		case .newUser(_, let isCurrentUser):
			return isCurrentUser ? nil : "Mention User"
		case .developer:
			return "Become a Developer"
		case .earlySupporter:
			return nil
		case .staff:
			return "Join Kurozora Staff"
		case .pro:
			return "Become a Pro User"
		case .subscriber:
			return "Become a Subscriber"
		case .verified:
			return "Get Verified"
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
