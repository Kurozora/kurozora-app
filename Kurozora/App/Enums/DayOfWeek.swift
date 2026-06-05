//
//  DayOfWeek.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Foundation

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
	/// The localized standalone name of the weekday.
	var name: String {
		let formatter = DateFormatter()
		formatter.locale = LanguageManager.shared.locale
		return formatter.standaloneWeekdaySymbols[self.rawValue]
	}
}
