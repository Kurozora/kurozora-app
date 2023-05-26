//
//  DayOfWeek.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum DayOfWeek: Int, CaseIterable {
	// MARK: - Cases
	case sunday = 0
	case monday = 1
	case tuesday = 2
	case wednesday = 3
	case thursday = 4
	case friday = 5
	case saturday = 6

	// MARK: - Properties
	/// The name value of a season.
	var name: String {
		switch self {
		case .sunday:
			return "Sunday"
		case .monday:
			return "Monday"
		case .tuesday:
			return "Tuesday"
		case .wednesday:
			return "Wednesday"
		case .thursday:
			return "Thursday"
		case .friday:
			return "Friday"
		case .saturday:
			return "Saturday"
		}
	}
}
