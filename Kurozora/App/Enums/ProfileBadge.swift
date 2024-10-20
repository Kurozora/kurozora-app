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
			return "\(username) is verified because it’s notable in animators, voice actors, entertainment studios, or another designated category."
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
			return R.image.badges.beginner_shield()
		case .developer:
			return R.image.badges.hammer_app()
		case .earlySupporter:
			return R.image.badges.bird_triangle()
		case .staff:
			return R.image.badges.sakura_shield()
		case .pro:
			return R.image.badges.rocket_circle()
		case .subscriber(_, let subscribedAt):
			let numberOfMonths = Date().months(from: subscribedAt)

			if numberOfMonths >= 24 {
				return R.image.badges.twenty_four_months()
			} else if numberOfMonths >= 18 {
				return R.image.badges.eighteen_months()
			} else if numberOfMonths >= 15 {
				return R.image.badges.fifteen_months()
			} else if numberOfMonths >= 12 {
				return R.image.badges.twelve_months()
			} else if numberOfMonths >= 9 {
				return R.image.badges.nine_months()
			} else if numberOfMonths >= 6 {
				return R.image.badges.six_months()
			} else if numberOfMonths >= 3 {
				return R.image.badges.three_months()
			} else if numberOfMonths >= 2 {
				return R.image.badges.two_months()
			} else {
				return R.image.badges.one_month()
			}
		case .verified:
			return R.image.badges.checkmark_seal()
		}
	}
}
