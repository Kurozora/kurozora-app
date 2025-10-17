//
//  SpecialDay.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/01/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation
import SPConfetti
import UIKit

enum SpecialDay: CaseIterable {
	case newYear		// January 1st
	case valentine		// February 14th
	case hinamatsuri	// March 3rd
	case whiteDay		// March 14th
	case childrensDay	// May 5th
	case tanabata		// July 7th
	case halloween		// October 31
	case christmasEve   // December 24
	case christmas		// December 25
	case newYearsEve	// December 31

	// Define the date range for each special day
	var dateRange: (start: DateComponents, end: DateComponents) {
		switch self {
		case .newYear:
			return (start: DateComponents(month: 1, day: 1), end: DateComponents(month: 1, day: 1))
		case .valentine:
			return (start: DateComponents(month: 2, day: 14), end: DateComponents(month: 2, day: 14))
		case .whiteDay:
			return (start: DateComponents(month: 3, day: 14), end: DateComponents(month: 3, day: 14))
		case .childrensDay:
			return (start: DateComponents(month: 5, day: 5), end: DateComponents(month: 5, day: 5))
		case .hinamatsuri:
			return (start: DateComponents(month: 3, day: 3), end: DateComponents(month: 3, day: 3))
		case .tanabata:
			return (start: DateComponents(month: 7, day: 7), end: DateComponents(month: 7, day: 7))
		case .halloween:
			return (start: DateComponents(month: 10, day: 31), end: DateComponents(month: 10, day: 31))
		case .christmasEve:
			return (start: DateComponents(month: 12, day: 24), end: DateComponents(month: 12, day: 24))
		case .christmas:
			return (start: DateComponents(month: 12, day: 25), end: DateComponents(month: 12, day: 25))
		case .newYearsEve:
			return (start: DateComponents(month: 12, day: 31), end: DateComponents(month: 12, day: 31))
		}
	}

	// Confetti configuration for each special day
	var confettiColors: [UIColor] {
		switch self {
		case .newYear:
			return [.systemYellow, .systemRed, .systemBlue, .systemGreen, .systemPurple, .systemPink, .systemCyan, .black, .white]
		case .valentine:
			return [.systemRed, .systemPink, .white]
		case .whiteDay:
			return [.white, .systemBrown, .brown, .systemCyan, .cyan]
		case .childrensDay:
			return [.systemBlue, .systemYellow, .systemGreen, .systemRed]
		case .hinamatsuri:
			return [.systemPink, .systemRed, .white]
		case .tanabata:
			return [.systemBlue, .systemPurple, .white, .systemYellow]
		case .halloween:
			return [.systemOrange, .systemYellow, .systemRed, .black, .systemPurple]
		case .christmasEve, .christmas:
			return [.systemGreen, .systemYellow, .systemRed, .white]
		case .newYearsEve:
			return [.systemYellow, .systemRed, .systemBlue, .systemGreen, .systemPurple]
		}
	}

	var confettiParticles: [SPConfettiParticle] {
		switch self {
		case .newYear, .newYearsEve:
			return [.arc, .triangle, .circle, .polygon, .star]
		case .valentine:
			return [.circle, .custom(UIImage(systemName: "heart.fill")!)]
		case .whiteDay:
			return [.circle, .custom(UIImage(systemName: "heart.fill")!)]
		case .childrensDay:
			return [.circle, .arc, .triangle, .custom(UIImage(systemName: "person.fill")!)]
		case .hinamatsuri:
			return [.circle, .custom(UIImage(systemName: "crown.fill")!), .custom(UIImage(systemName: "gift.fill")!)]
		case .tanabata:
			return [.star, .custom(UIImage(systemName: "star.fill")!), .circle, .arc]
		case .halloween:
            return [.arc, .custom(.spiderWeb), .custom(.witchOnBroom), .custom(.pumpkin)]
		case .christmasEve, .christmas:
			return [.arc, .triangle, .circle, .custom(UIImage(systemName: "star.fill")!), .custom(UIImage(systemName: "snowflake")!), .custom(UIImage(systemName: "gift.fill")!)]
		}
	}

	// Check if today's date falls within the special day's range
	func isToday() -> Bool {
		let calendar = Calendar.current
		let today = calendar.dateComponents([.month, .day], from: Date())

		if let todayDate = calendar.date(from: today),
		   let startDate = calendar.date(from: self.dateRange.start),
		   let endDate = calendar.date(from: self.dateRange.end) {
			return todayDate >= startDate && todayDate <= endDate
		}

		return false
	}
}
