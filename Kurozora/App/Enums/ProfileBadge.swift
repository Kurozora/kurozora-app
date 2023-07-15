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
	case developer
	case earlyBird
	case staff
	case pro
	case subscriber(sinceDate: Date)
	case verified

	// MARK: - Properties
	/// The description value of a profile badge.
	var description: String {
		switch self {
		case .developer:
			return "This account is an active developer."
		case .earlyBird:
			return "This account is an early supporter of Kurozora."
		case .staff:
			return "This account is a staff member."
		case .pro:
			return "This account is a Pro user."
		case .subscriber(let sinceDate):
			return "This account is a Kurozora+ subscriber since \(sinceDate.formatted(date: .abbreviated, time: .omitted))."
		case .verified:
			return "This account is a staff member."
		}
	}

	/// The image value of a profile badge.
	var image: UIImage? {
		switch self {
		case .developer:
			return R.image.badges.hammer_app()
		case .earlyBird:
			return R.image.badges.bird_triangle()
		case .staff:
			return R.image.badges.sakura_shield()
		case .pro:
			return R.image.badges.rocket_circle()
		case .subscriber(let sinceDate):
			let numberOfMonths = Date().months(from: sinceDate)

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
